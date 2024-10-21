FROM python:3

ADD date.py .
WORKDIR .
RUN apt update
 
CMD ["python", "./date.py"]
