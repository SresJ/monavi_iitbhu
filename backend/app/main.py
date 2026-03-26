from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager

from app.config import settings
from app.database import connect_to_mongo, close_mongo_connection
from app.middleware.firebase_middleware import initialize_firebase

# Import routers
from app.api import auth, patients, analysis, followup, export


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager - runs on startup and shutdown
    """
    # Startup
    print(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")

    # Initialize Firebase Admin SDK
    initialize_firebase()

    # Connect to MongoDB
    await connect_to_mongo()

    yield

    # Shutdown
    print("Shutting down application...")
    await close_mongo_connection()


# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Clinical Dashboard API with ML-powered diagnosis system",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

# =============================================================================
# CORS Configuration for Flutter Web Production
# =============================================================================
# Why this configuration:
# 1. allow_origins=["*"] - Allows requests from any origin (Flutter Web on any domain)
# 2. allow_credentials=False - REQUIRED when using "*" origins (browser security rule)
#    We use Authorization header (Bearer token) instead of cookies, so this is fine
# 3. allow_methods=["*"] - Permits all HTTP methods including OPTIONS preflight
# 4. allow_headers=["*"] - Allows all headers including Authorization, Content-Type
# 5. expose_headers - Makes these headers readable by JavaScript in Flutter Web
#    Without this, Flutter's http/dio packages cannot read custom response headers
# =============================================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=[
        "Content-Length",
        "Content-Type",
        "X-Request-ID",
        "X-RateLimit-Limit",
        "X-RateLimit-Remaining",
    ],
)


# Root endpoint
@app.get("/", tags=["Root"])
async def root():
    """
    Root endpoint - API health check
    """
    return {
        "message": f"Welcome to {settings.APP_NAME}",
        "version": settings.APP_VERSION,
        "status": "running",
        "docs": "/docs"
    }


# =============================================================================
# Health Endpoint for Flutter Web Connectivity Checks
# =============================================================================
# This endpoint is designed specifically for Flutter Web production use:
# 1. Returns minimal payload for fast response
# 2. Cache-Control: no-store prevents browser/SW from caching stale responses
# 3. Always returns 200 OK if server is reachable
# 4. Flutter should check response.statusCode == 200, NOT parse body
# =============================================================================
@app.get("/health", tags=["Root"])
async def health_check():
    """
    Health check endpoint for Flutter Web connectivity verification.

    Flutter Web Usage:
    ```dart
    Future<bool> checkConnectivity() async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/health'),
        ).timeout(Duration(seconds: 5));
        return response.statusCode == 200;
      } catch (e) {
        return false;
      }
    }
    ```
    """
    return JSONResponse(
        content={
            "status": "healthy",
            "version": settings.APP_VERSION
        },
        headers={
            "Cache-Control": "no-store, no-cache, must-revalidate, max-age=0",
            "Pragma": "no-cache",
        }
    )


# Register API routers
app.include_router(auth.router, prefix="/api")
app.include_router(patients.router, prefix="/api")
app.include_router(analysis.router, prefix="/api")
app.include_router(followup.router, prefix="/api")
app.include_router(export.router, prefix="/api")


# =============================================================================
# Error Handlers with CORS Headers
# =============================================================================
# CRITICAL: Error responses MUST include CORS headers, otherwise Flutter Web
# receives a network error instead of the actual error response.
# The browser blocks reading the response body if CORS headers are missing.
# =============================================================================
def _cors_headers(request: Request) -> dict:
    """Generate CORS headers for error responses."""
    origin = request.headers.get("origin", "*")
    return {
        "Access-Control-Allow-Origin": origin if origin else "*",
        "Access-Control-Allow-Methods": "*",
        "Access-Control-Allow-Headers": "*",
    }


@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    return JSONResponse(
        status_code=404,
        content={
            "error": "Not Found",
            "detail": "The requested resource was not found",
            "path": str(request.url)
        },
        headers=_cors_headers(request)
    )


@app.exception_handler(500)
async def internal_error_handler(request: Request, exc):
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "detail": "An unexpected error occurred. Please try again later."
        },
        headers=_cors_headers(request)
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=10000,
        reload=settings.DEBUG
    )
