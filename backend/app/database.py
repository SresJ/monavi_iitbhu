from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from typing import Optional
from app.config import settings


class MongoDB:
    """
    MongoDB connection manager using Motor (async MongoDB driver)
    """
    client: Optional[AsyncIOMotorClient] = None
    db: Optional[AsyncIOMotorDatabase] = None


mongodb = MongoDB()


async def connect_to_mongo():
    """
    Connect to MongoDB and create database instance
    """
    print(f"Connecting to MongoDB")
    mongodb.client = AsyncIOMotorClient(settings.MONGODB_URI)
    mongodb.db = mongodb.client[settings.MONGODB_DB_NAME]

    # Create indexes
    await create_indexes()

    print(f"Successfully connected to MongoDB database: {settings.MONGODB_DB_NAME}")


async def close_mongo_connection():
    """
    Close MongoDB connection
    """
    if mongodb.client:
        mongodb.client.close()
        print("MongoDB connection closed")


async def create_indexes():
    """
    Create MongoDB indexes for better query performance
    """
    if mongodb.db is None:
        return

    # Doctors collection indexes
    await mongodb.db.doctors.create_index("firebase_uid", unique=True)
    await mongodb.db.doctors.create_index("email", unique=True)

    # Patients collection indexes
    await mongodb.db.patients.create_index("patient_id", unique=True)
    await mongodb.db.patients.create_index("mrn", unique=True, sparse=True)
    await mongodb.db.patients.create_index("full_name")

    # Analyses collection indexes
    await mongodb.db.analyses.create_index("analysis_id", unique=True)
    await mongodb.db.analyses.create_index("patient_id")
    await mongodb.db.analyses.create_index("doctor_firebase_uid")
    await mongodb.db.analyses.create_index("created_at")

    # Followup conversations collection indexes
    await mongodb.db.followup_conversations.create_index("analysis_id")

    print("MongoDB indexes created successfully")


def get_database() -> AsyncIOMotorDatabase:
    """
    Get database instance for dependency injection
    """
    return mongodb.db
