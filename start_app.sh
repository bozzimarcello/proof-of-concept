#!/bin/bash

echo "Starting React + FastAPI Authentication App..."
echo "=============================================="

# Check if we can run both in separate terminals or sequentially
read -p "Do you want to start both frontend and backend? (y/n): " choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo "Starting backend in background..."
    cd backend || exit
    
    # Check if virtual environment exists
    if [ -d "venv" ]; then
        echo "Activating virtual environment..."
        source venv/bin/activate
    fi
    
    # Start FastAPI server in background
    uvicorn main:app --reload &
    BACKEND_PID=$!
    
    echo "Backend started with PID: $BACKEND_PID"
    echo "Backend will be available at http://localhost:8000"
    
    # Give backend a moment to start
    sleep 2
    
    echo "Starting frontend..."
    cd ../frontend || exit
    npm start
    
    # When frontend stops, kill backend
    kill $BACKEND_PID
    
else
    echo "Please start frontend and backend manually:"
    echo "1. Backend: cd backend && uvicorn main:app --reload"
    echo "2. Frontend: cd frontend && npm start"
fi