.PHONY: \
	env-create env-destroy env-down env-rmi env-build env-top env-images \
	net-init net-deinit \
	go-build go-up go-console go-stop go-down go-rmi

# 変数 --------------------------
# git for windows/MySYS2とかWindows環境ではwinpty仮想端末経由でdocker/docker-composeを実行
ifeq ($(OS),Windows_NT)
D=winpty docker
DC=winpty docker-compose -f docker-compose.dev.yml
else
D=docker
DC=docker-compose -f docker-compose.dev.yml
endif

# network addressを.envから取得
NETWORK_ADDR := $(shell grep 'NETWORK_ADDR' .env | sed -r 's/NETWORK_ADDR=(.+)/\1/g' )
# gateway addressを.envから取得
NETWORK_GATEWAY_IP := $(shell grep 'NETWORK_GATEWAY_IP' .env | sed -r 's/NETWORK_GATEWAY_IP=(.+)/\1/g' )

# 環境 --------------------------
# docker network作成、imageビルド
env-create: net-init env-build

# docker container停止/破棄、image破棄、network破棄
env-destroy: env-rmi net-deinit

# docker container停止/破棄
env-down:
	-$(DC) down

# docker container停止/破棄、image破棄
env-rmi:
	-$(DC) down --rmi all

# docker imageビルド
env-build: go-build blog-build

# top
env-top:
	$(DC) top

# ネットワーク -------------------
# docker network作成
net-init:
	-$(D) network create --driver=bridge --subnet=$(NETWORK_ADDR) --gateway=$(NETWORK_GATEWAY_IP) dev-env-link

# docker network破棄
net-deinit:
	-$(D) network remove dev-env-link

# golang環境 ---------------------
# golang環境 imageビルド
go-build:
	$(DC) build --force golang

# golang環境 container実行
go-up:
	$(DC) up -d golang

# golang環境 container実行、同一コンテナでbash実行
go-console: go-up
	$(DC) exec golang bash

# golang環境 container停止
go-stop:
	-$(DC) stop golang

# golang環境 container停止/破棄
go-down: go-stop
	-$(DC) rm -f golang

# golang環境 container停止/破棄、image破棄
go-rmi: go-down
	-$(D) rmi -f dev-env-golang-image

# blog環境 ---------------------
# blog環境 imageビルド
blog-build:
	$(DC) build --force blog

# blog環境 container実行
blog-up:
	$(DC) up -d blog

# blog環境 container実行、同一コンテナでbash実行
blog-console: blog-up
	$(DC) exec blog bash

# blog環境 container停止
blog-stop:
	-$(DC) stop blog

# blog環境 container停止/破棄
blog-down: blog-stop
	-$(DC) rm -f blog

# blog環境 container停止/破棄、image破棄
blog-rmi: blog-down
	-$(D) rmi -f dev-env-blog-image
