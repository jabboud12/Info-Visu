class CylinderGenerator {

    ArrayList<Cylinder> cylinders;

    // source position 
    

    CylinderGenerator(){
        cylinders = new ArrayList();
    }

    CylinderGenerator(float x , float y){
        cylinders = new ArrayList();
        cylinders.add( new Cylinder(x,y) );
    }

    void draw(){
        for ( Cylinder c : cylinders)
            c.draw();
    }

    void drawShitMode(){
        for( Cylinder c : cylinders)
            c.drawShitMode();
    }


    boolean isInside(MovingBall ball){
        return cylinders.get(0).isInside(ball);
    }

    void update( Plate plate , MovingBall ball ){

        

        if( cylinders.isEmpty()  )
            return ;

        
        for( int i=0; i< cylinders.size() ; i++){
            if( cylinders.get(i).isInside(ball) ) {
                if(i == 0) {
                    // Yeah you killed the SOURCE !!
                    cylinders = new ArrayList();
                    return;
                }
                cylinders.remove(i);
                i = i-1;
            }
            
        }

        if (frameCount % 50 != 0 )
            return ;

        
        int numAttempts = 100;

        for(int i=0; i< numAttempts ; i++) {

            // Pick a cylinder and its center.
            int index = int(random(cylinders.size()));
            Cylinder new_cylinder = cylinders.get(index).copy();
           

            // Try to add an adjacent cylinder.
            float angle = random(TWO_PI);
            new_cylinder.x += sin(angle) * 2 * new_cylinder.cylinderBaseSize;
            new_cylinder.y += cos(angle) * 2 * new_cylinder.cylinderBaseSize;


            boolean noCylinderCollision = true;
            for(Cylinder c1 : cylinders)
                if(c1.isInside(new_cylinder)) noCylinderCollision = false;
            
            

            // TODO : i dont understant why it doesn t work wtith isInside uncommented ?
            if(plate.isInside(new_cylinder) /* && new_cylinder.isInside(ball)*/ && noCylinderCollision) {
                cylinders.add(new_cylinder);
                break;
            }
            


        }

    }




}