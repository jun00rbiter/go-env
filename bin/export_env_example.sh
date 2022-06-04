#!/bin/bash
cat .env | sed -r 's/(USER_NAME|USER_PW|GROUP_NAME)=.*/\1=/g' > .env.example
cat .env.example
