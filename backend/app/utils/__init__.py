from datetime import datetime, timezone, timedelta

# Indian Standard Time (IST) is UTC+5:30
IST = timezone(timedelta(hours=5, minutes=30))


def get_ist_now() -> datetime:
    """
    Get current datetime in IST (Indian Standard Time, UTC+5:30)

    Returns:
        datetime: Current datetime in IST timezone
    """
    return datetime.now(IST)
