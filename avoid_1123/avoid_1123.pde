import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress remoteAddoress; 

int x,y;
int drawflg;
int mouseLocx,mouseLocy;

int TM = 10; //タイマーの時間
boolean running = false; 
int tm0;
int tm;

boolean C1,Hit;
float C1y,avoidX;
float speed = 10.0;
float Cx = width/2;

void setup() {
  size(500,600);
  frameRate(100);

  oscP5 = new OscP5(this,12001);
  remoteAddoress = new NetAddress("127.0.0.1",12002);
}

void draw() {
  background(200);
  
  stroke(0);
  strokeWeight(1);
  
  background(120);
  
  //hitの操作
  stroke(0);
  strokeWeight(1); 

  ellipse(Cx,C1y,50,50);//落ちてくる円の大きさ変更
  fill(0);
  
  //avoidの操作
  noStroke();
  fill(220,100,100);
  ellipse(x,500,30,30);
  
  if (running) {
    tm = TM*1000 - (millis() - tm0);
    x = mouseX;
    
    if(tm <= 0){
      tm = 0;
      running = false; //タイマー停止
    }
  } 
  else {
    tm = TM*1000;//待機状態
    x = width/2;
  }
  
  fill(0);
  textAlign(LEFT,TOP); //時間の表示
  text(tm/1000, 10, 10);
  
  
  stroke(0);
  strokeWeight(1);
  
  OscMessage msg = new OscMessage("/mouse/position");
  msg.add(x);
  oscP5.send(msg,remoteAddoress);
}


void mousePressed(){
  running = true;
  tm0 = millis();//カウントダウン開始
  
  OscMessage msg = new OscMessage("/mouse/cliked");
  msg.add(1); //1を送信
  //OSCメッセージ送信
  oscP5.send(msg,remoteAddoress);
}

void oscEvent(OscMessage msg) {
  if(msg.checkAddrPattern("/en/position")==true) {
    Cx = msg.get(0).floatValue();
    C1y = msg.get(1).floatValue();
  }
}
