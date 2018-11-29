import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remoteAddoress;

int x, y, count;
float C1y, avoidX;
boolean drawflg, C1, Hit;
int mouseLocx;
PImage Dorobou,Police;
float Cx = width/2;

//float C1dist = dist(Cx,C1y,mouseX,mouseY);
//float C1Avoid = dist(Cx,C1y,mouseLocx,500);
int speed = 10;

int TM = 10; //タイマーの時間
int tm0;
int tm;

int running;

void setup() {
  size(500, 600);
  frameRate(100);
  
  Dorobou = loadImage("dorobou_shinobiashi.png");
  Police = loadImage("police_man_kenju_gun.png");

  oscP5 = new OscP5(this, 12002);
  remoteAddoress = new NetAddress("127.0.0.1", 12001);
   //remoteAddoress = new NetAddress("10.202.10.227", 12001);//ドーナツ　

  running = 0;

  x = mouseX;
  y = mouseY;
  C1 = false;
  Hit = false;
}

void draw() {
  float C1Avoid = dist(x, 500, 30, 30);
  stroke(0);
  strokeWeight(1);

  background(120);

  image(Police,Cx, C1y, 100, 100);//落ちてくる円の大きさ変更

  if ( C1 ) {

    C1y += 5;
    C1y = C1y % height;
  } else {
    C1y = 5;
  }

  if (C1 == true && C1y > 590) {
    C1 = false;
  }


  println(C1Avoid);//1Pと2Pの距離判定

  float dx, dy, dr;
  dx = abs(Cx - x);
  dy = abs(C1y - 500);
  dr = 50/2 + 30/2;
  Hit = sqrt(sq(dx) + sq(dy)) < dr;

  if (Hit) {//当たり判定（正確に判定できてない）
    Hit = true;
    println("hit");
    text("1P WIN!!!", width/2, height/2);
    noLoop();
    OscMessage Hit = new OscMessage("/Hit/True");
    Hit.add(1);
    oscP5.send(Hit,remoteAddoress);
    
  } else {
    Hit = false;
  }

  if (Hit) {
    return;
  }

  //avoid 操作
  noStroke();
  fill(220, 100, 100);
  image(Dorobou,x,500,100,100);
  if (running == 1) {
    tm = TM*1000 - (millis() - tm0);
    x = mouseLocx;

    if (tm <= 0) {
      tm = 0;
      running = 0; //タイマー停止
    }
  } else {
    tm = TM*1000;//待機状態
    x = width/2;
   
  }

  fill(0);
  textAlign(LEFT, TOP); //時間の表示
  text(tm/1000, 10, 10);


  OscMessage msg = new OscMessage("/en/position");
  msg.add(Cx);
  msg.add(C1y);
  oscP5.send(msg, remoteAddoress);
}


void keyPressed() {
  if (key == CODED) { 
    if (keyCode == RIGHT) {
      Cx += speed;
    } else if (keyCode == LEFT) {
      Cx -= speed;
    } else if (keyCode == DOWN) {
      C1 = true;
    } else {
      C1 = false;
    }
  }

  if (key == ' ') {
    startPoint();
    println("Start");
    OscMessage Startmsg = new OscMessage("/Key/Space/Pressed");
    Startmsg.add(1);
    oscP5.send(Startmsg,remoteAddoress);
  }
}

void startPoint() {
  Cx = width/2;
  C1 = false;
  loop();
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/mouse/position")==true) {
    mouseLocx = msg.get(0).intValue();
  }

  if (msg.checkAddrPattern("/mouse/cliked")==true) {
    //Bool値を読み込み
    running = msg.get(0).intValue();
    println("msg = " + running);
    print("*");
    tm0 = millis();//カウントダウン開始
  }
  
  if(msg.checkAddrPattern("/Key/Space/Pressed")==true){
    startPoint();
  }
}
