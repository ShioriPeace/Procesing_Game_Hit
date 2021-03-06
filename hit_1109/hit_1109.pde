import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress remoteAddoress;

int x,y,count;
float C1y,avoidX;
boolean drawflg,C1,Hit;
int mouseLocx;

float Cx = 200;

//float C1dist = dist(Cx,C1y,mouseX,mouseY);
//float C1Avoid = dist(Cx,C1y,mouseLocx,500);
float speed = 10.0;

int TM = 10; //タイマーの時間
int tm0;
int tm;

int running;

void setup() {
  size(500,600);
  frameRate(100);
 
  oscP5 = new OscP5(this,12002);
  remoteAddoress = new NetAddress("127.0.0.1",12001);
  
  running = 0;
  
  x = mouseX;
  y = mouseY;
  C1 = false;
  Hit = false;
}

void draw() {
  //float C1Avoid = dist(Cx,C1y,mouseLocx,500);
  stroke(0);
  strokeWeight(1);
  
  background(120);
  
  ellipse(Cx,C1y,50,50);//落ちてくる円の大きさ変更
  
  if( C1 ){
    
  C1y += 5;
  C1y = C1y % height;
  }else{
    C1y = 5;
  }
  
  if(C1 == true && C1y > 590){
    C1 = false;
  }
  
  if(isBallTouch()){
    text("1P WIN!!!",width/2,height/2);
    noLoop();
    
  }
  
  OscMessage Hitmsg = new OscMessage("/Key/Pressed");
  Hitmsg.add(Cx);
  Hitmsg.add(C1y);
  oscP5.send(Hitmsg,remoteAddoress);
  
 /* println(C1Avoid);//1Pと2Pの距離判定
  if(C1Avoid < 235){//当たり判定（正確に判定できてない）
    Hit = true;
    println("hit");
    text("1P WIN!!!",width/2,height/2);
    noLoop();
    
  }else{
    Hit = false;
  }
  
  if(Hit){
    return;
  }*/
  
  
  
 //avoid 操作
 noStroke();
 fill(220,100,100);
 ellipse(x,500,30,30);
 if (running == 1) {
    tm = TM*1000 - (millis() - tm0);
    x = mouseLocx;
    
    if(tm <= 0){
      tm = 0;
      running = 0; //タイマー停止
    }
  } 
  else {
    tm = TM*1000;//待機状態
    x = width/2;
  }
  
  fill(0);
  textAlign(LEFT,TOP); //時間の表示
  text(tm/1000, 10, 10);

  
  OscMessage sendValue = new OscMessage("/mouse/position");
  sendValue.add(mouseX);
  sendValue.add(mouseY);
  
  oscP5.send(sendValue,remoteAddoress);
}
  

boolean isBallTouch(){
  float distX;
  float distY;
  float distRadius;
  float dist;
  
  distX = Cx-x;
  distY = C1y-500;
  distRadius = 70;
  dist = sqrt( sq(distX)+sq(distY) );
  
  
  println(dist);
  
  return(dist < distRadius);
  
}



void keyPressed(){
  if(key == CODED){
    if(keyCode == RIGHT){
      Cx += speed;
    }else if(keyCode == LEFT){
      Cx -= speed;
    }else if(keyCode == DOWN){
      C1 = true;
    }else if(keyCode == ENTER){
      Hit = true;
    }
    else{
      C1 = false;
    }
  }
  
  OscMessage sendHitValue = new OscMessage("/Key/Pressed");
  sendHitValue.add(1);
  //OSCメッセ送信
  oscP5.send(sendHitValue,remoteAddoress);
  
}



/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage msg) {
  if(msg.checkAddrPattern("/Android")==true) {
    mouseLocx = msg.get(0).intValue(); //avoid のx座標
  }
  
    if(msg.checkAddrPattern("/mouse/cliked")==true) {
    //Bool値を読み込み
    running = msg.get(0).intValue();
    println("msg = " + running);
    print("*");
    tm0 = millis();//カウントダウン開始
  }
}
