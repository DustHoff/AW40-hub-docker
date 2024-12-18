from typing import Optional

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    api_allow_origins: str
    mongo_host: str
    mongo_port: str
    mongo_username: str
    mongo_password: str
    mongo_db: str

    redis_password: str
    redis_host: str = "redis"
    redis_port: str = "6379"

    knowledge_graph_url: Optional[str] = "http://knowledge-graph:3030"

    keycloak_url: str = "http://keycloak:8080"
    keycloak_workshop_realm: str = "werkstatt-hub"

    nautilus_url: str = "http://nautilus:3000/nautilus"
    nautilus_timeout: int = 120

    api_key_diagnostics: str

    api_key_assets: str

    exclude_diagnostics_router: bool = False

    @property
    def mongo_uri(self):
        username = self.mongo_username
        password = self.mongo_password
        host = self.mongo_host
        port = self.mongo_port

        return (
            f"mongodb://{username}:{password}"
            f"@{host}:{port}/?authSource=admin"
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


settings = Settings()  # type: ignore
