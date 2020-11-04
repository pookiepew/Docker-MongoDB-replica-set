FROM mongo:latest

COPY ./mongo.key /opt/

RUN chmod 700 /opt/mongo.key && chown mongodb:mongodb /opt/mongo.key

EXPOSE 27017

CMD ["mongod"]