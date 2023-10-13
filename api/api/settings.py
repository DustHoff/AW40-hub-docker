from typing import Optional

from pydantic import BaseSettings


class Settings(BaseSettings):
    api_allow_origins: str
    mongo_host: str
    mongo_username: str
    mongo_password: str
    mongo_db: str
    minio_host: str
    minio_username: str
    minio_password: str

    redis_password: str
    redis_host: str = "redis"
    redis_port: str = "6379"

    knowledge_graph_url: Optional[str] = None

    @property
    def mongo_uri(self):
        username = self.mongo_username
        password = self.mongo_password
        host = self.mongo_host

        return (
            f"mongodb://{username}:{password}"
            f"@{host}:27017/?authSource=admin"
        )

    @property
    def allowed_origins(self):
        return [x for x in self.api_allow_origins.split(',') if x]

    @property
    def redis_uri(self):
        return (
            f"redis://:{self.redis_password}@{self.redis_host}"
            f":{self.redis_port}"
        )


settings = Settings()
