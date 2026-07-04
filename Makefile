NAME		= inception
COMPOSE		= srcs/docker-compose.yml
DATA_PATH	= $(HOME)/data

all: up

up:
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	@docker compose -f $(COMPOSE) up -d --build

down:
	@docker compose -f $(COMPOSE) down

stop:
	@docker compose -f $(COMPOSE) stop

start:
	@docker compose -f $(COMPOSE) start

status:
	@docker compose -f $(COMPOSE) ps

logs:
	@docker compose -f $(COMPOSE) logs -f

build:
	@docker compose -f $(COMPOSE) build

re: down up

clean: down
	@docker compose -f $(COMPOSE) down --rmi all -v

fclean: clean
	@sudo rm -rf $(DATA_PATH)
	@docker system prune -af

.PHONY: all up down stop start status logs build re clean fclean
