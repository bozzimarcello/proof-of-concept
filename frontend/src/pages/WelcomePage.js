import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Container, Row, Col, Button, Card, Alert, Spinner } from 'react-bootstrap';

function WelcomePage({ user, token, onLogout }) {
  const [welcomeContent, setWelcomeContent] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchWelcomeContent = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Call the protected endpoint
        const response = await axios.get('http://localhost:8000/welcome', {
          params: {
            token: token,
            username: user.username
          }
        });
        
        setWelcomeContent(response.data);
        
      } catch (err) {
        console.error('Error fetching welcome content:', err);
        setError(err.response?.data?.detail || 'Failed to load welcome content');
      } finally {
        setLoading(false);
      }
    };

    fetchWelcomeContent();
  }, [token, user.username]);

  const handleLogout = () => {
    // Clear localStorage
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    
    // Call parent component's logout handler
    onLogout();
    
    // Navigate to login page
    navigate('/login');
  };

  return (
    <Container className="d-flex align-items-center justify-content-center min-vh-100">
      <Row className="w-100">
        <Col md={8} lg={6} className="mx-auto">
          <Card className="shadow">
            <Card.Body>
              <Card.Title className="text-center mb-4">Welcome</Card.Title>
              
              {error && (
                <Alert variant="danger" className="mb-3">
                  {error}
                </Alert>
              )}
              
              {loading ? (
                <div className="text-center my-5">
                  <Spinner animation="border" role="status">
                    <span className="visually-hidden">Loading...</span>
                  </Spinner>
                </div>
              ) : welcomeContent ? (
                <div>
                  <h4 className="mb-3">Hello, {user.full_name || user.username}!</h4>
                  <p className="lead">{welcomeContent.message}</p>
                  
                  <div className="mt-4 text-center">
                    <p>You have successfully authenticated and accessed protected content.</p>
                    <Button
                      variant="outline-danger"
                      onClick={handleLogout}
                      className="mt-3"
                    >
                      Logout
                    </Button>
                  </div>
                </div>
              ) : null}
            </Card.Body>
          </Card>
        </Col>
      </Row>
    </Container>
  );
}

export default WelcomePage;