JSONObject featureColl;

ArrayList<Feature> features;
ArrayList<Feature> steve;
ArrayList<Feature> john;
ArrayList<Feature> gb;

PFont font;

PVector min;
PVector max;
float scale;
int minT;
//int maxT;
int timestep = 60;  // in expedition-minutes per real-seconds

int counter;

void setup() {
  size(800,600);
  colorMode(HSB);
  background(255);
  smooth();
  frameRate(30);
  font = createFont("Anivers", 24);
  textFont(font);
  textAlign(LEFT, TOP);
  features = new ArrayList<Feature>();
  steve = new ArrayList<Feature>();
  john = new ArrayList<Feature>();
  gb = new ArrayList<Feature>();
  JSONArray fs = null;

  int date = 8;  // sept 8th 2013
  
  do {
    String datestr = "" + date;
    if (date < 10) {
      datestr = "0" + datestr;
    }
    println(datestr);
    featureColl = loadJSONObject(
      "http://intotheokavango.org/api/timeline?date=201309" + datestr + "&types=ambit_geo");
    fs = featureColl.getJSONArray("features");
    for (int i = 0; i < fs.size(); i++) {
      JSONObject thing = fs.getJSONObject(i); 
      Feature n = new Feature(thing);
      features.add(n);
      if (n.person.equals("John")) {
        john.add(n);
      } else if (n.person.equals("Steve")) {
        steve.add(n);
      } else if (n.person.equals("GB")) {
        gb.add(n);
      } else {
        println("who the heck is " + n.person + "?");
      }
    }
    date++;
  } while (fs.size() > 0);


  PVector c = features.get(0).coords;  
  min = new PVector(c.x, c.y, c.z);
  max = new PVector(c.x, c.y, c.z);
  minT = features.get(0).time;
//  maxT = features.get(0).time;

  for (int i=0; i < features.size(); i++) {
    PVector j = features.get(i).coords;
    if (j.x < min.x) {
      min.x = j.x;
    }
    if (j.y < min.y) {
      min.y = j.y;
    }
    if (j.z < min.z) {
      min.z = j.z;
    }
    if (j.x > max.x) {
      max.x = j.x;
    }
    if (j.y > max.y) {
      max.y = j.y;
    }
    if (j.z > max.z) {
      max.z = j.z;
    }
    if (features.get(i).time < minT) {
      minT = features.get(i).time;
    }
//    if (features.get(i).time > maxT) {
//      maxT = features.get(i).time;
//    }
  }
  println(min.toString());
  println(max.toString());
  counter = minT;

  float xscale = width / (max.x - min.x);
  float yscale = height / (max.y - min.y);
  if (xscale < yscale) {
    scale = xscale;
  } else {
    scale = yscale;
  }
}

void draw() {
  background(255);
  counter += (timestep * 60) / frameRate;
  strokeWeight(2);
  
  fill(0);
  stroke(0);
  text("Time: " + counter, 10, 10);
  
  for (int i=1; i < steve.size()-1; i++) {  //counter < steve.size()) {
    if (steve.get(i).time < counter) {
      PVector startS = convert(steve.get(i-1).coords);
      PVector endS = convert(steve.get(i).coords);
      stroke(0, 255, endS.z, 128);
      line(startS.x, startS.y, endS.x, endS.y);
    }
  }
  for (int i=1; i < john.size()-1; i++) {  //counter < john.size()) {
    if (john.get(i).time < counter) {
      PVector startJ = convert(john.get(i-1).coords);
      PVector endJ = convert(john.get(i).coords);
      stroke(75, 255, endJ.z, 128);
      line(startJ.x, startJ.y, endJ.x, endJ.y);
    }
  }
  for (int i=1; i < gb.size()-1; i++) {  //counter < gb.size()) {
    if (gb.get(i).time < counter) {
      PVector startG = convert(gb.get(i-1).coords);
      PVector endG = convert(gb.get(i).coords);
      stroke(200, 255, endG.z, 128);
      line(startG.x, startG.y, endG.x, endG.y);
    }
  }
  
}

class Feature {
  PVector coords;
  String person;
  int time;
  
  Feature(JSONObject f) {
    JSONArray c = f.getJSONObject("geometry").getJSONArray("coordinates");
    coords = new PVector(c.getFloat(0), c.getFloat(1), c.getFloat(2));
    
    JSONObject p = f.getJSONObject("properties");
    person = p.getString("Person");
    time = p.getInt("t_utc");
    
    //debug!
    int id = f.getInt("id");
    println(id);
  }
}

// convert from GPS to on-screen
PVector convert(PVector c) {
  PVector r = new PVector();
  r.x = (c.x - min.x) * scale;
  r.y = height - ((c.y - min.y) * scale);
  // converting z values to a color range
  r.z = (c.z - min.z) / (max.z - min.z) * 128;
  //println(c.x + ", " + c.y + ", " + c.z + " -> " + r.x + ", " + r.y + ", " + r.z);
  return r;
}
