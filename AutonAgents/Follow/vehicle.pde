class Vehicle {
  
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    
  float maxspeed;    

  Vehicle(float x, float y) {
    acceleration = new PVector(0,0);
    velocity = new PVector(0,-2);
    position = new PVector(x,y);
    r = 6;
    maxspeed = 4;
    maxforce = 0.1;
  }

  // Method to update position
  void update() {

    velocity.add(acceleration);

    velocity.limit(maxspeed);
    position.add(velocity);

    acceleration.mult(0);
  }

  void applyForce(PVector force) {

    acceleration.add(force);
  }


  void seek(PVector target) {
    PVector desired = PVector.sub(target,position);  
    

    desired.setMag(maxspeed);

   
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  
    
    applyForce(steer);
  }
    
  void display() {

    float theta = velocity.heading2D() + PI/2;
    fill(127);
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate(position.x,position.y);
    rotate(theta);
    beginShape();
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape(CLOSE);
    popMatrix();
    
    
  }
}
