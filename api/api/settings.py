from pydantic import BaseSettings


class Settings(BaseSettings):
    mongo_host: str
    mongo_username: str
    mongo_password: str
    mongo_db: str

    redis_host: str

    @property
    def mongo_uri(self):
        username = self.mongo_username
        password = self.mongo_password
        host = self.mongo_host

        return f"mongodb://{username}:{password}" \
               f"@{host}:27017/?authSource=admin"

    @property
    def redis_uri(self):
        return f"redis://{self.redis_host}:6379"


settings = Settings()
