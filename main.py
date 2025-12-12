from fastapi import FastAPI

app = FastAPI()

@app.get("/hello")
def say_hello():
    return {"message": "Hello from OpenShift!"}

@app.get("/")
def root():
    return {"status": "running", "source": "openshift"}
