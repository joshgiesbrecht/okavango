JSONObject featureColl;

ArrayList<Feature> features;
ArrayList<Feature> steve;
ArrayList<Feature> john;
ArrayList<Feature> gb;

PVector min;
PVector max;
float scale;

int counter;

void setup() {
  size(800,600);
  colorMode(HSB);
  background(255);
  smooth();
  counter = 0;
  featureColl = loadJSONObject(
    "http://intotheokavango.org/api/timeline?date=20130908&types=ambit_geo");
  
  features = new ArrayList<Feature>();
  steve = new ArrayList<Feature>();
  john = new ArrayList<Feature>();
  gb = new ArrayList<Feature>();
  JSONArray fs = featureColl.getJSONArray("features");

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


  PVector c = features.get(0).coords;  
  min = new PVector(c.x, c.y, c.z);
  max = new PVector(c.x, c.y, c.z);

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
  }
  println(min.toString());
  println(max.toString());

  float xscale = width / (max.x - min.x);
  float yscale = height / (max.y - min.y);
  if (xscale < yscale) {
    scale = xscale;
  } else {
    scale = yscale;
  }

}

void draw() {
  counter += 10;
  strokeWeight(2);
  
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
  float time;
  
  Feature(JSONObject f) {
    JSONArray c = f.getJSONObject("geometry").getJSONArray("coordinates");
    coords = new PVector(c.getFloat(0), c.getFloat(1), c.getFloat(2));
    
    JSONObject p = f.getJSONObject("properties");
    person = p.getString("Person");
    time = p.getFloat("Time");
    
    //debug!
    int id = f.getInt("id");
    println(id);
  }
}

// convert from GPS to on-screen
PVector convert(PVector c) {
  PVector r = new PVector();
  r.x = (c.x - min.x) * scale;
  r.y = (c.y - min.y) * scale;
  // converting z values to a color range
  r.z = (c.z - min.z) / (max.z - min.z) * 128;
  //println(c.x + ", " + c.y + ", " + c.z + " -> " + r.x + ", " + r.y + ", " + r.z);
  return r;
}
