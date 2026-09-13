#include <Arduino.h>
#include <esp32-ps2dev.h>  // Emulate a PS/2 device

const int CLK_PIN = 17;
const int DATA_PIN = 16;

esp32_ps2dev::PS2Mouse mouse(CLK_PIN, DATA_PIN);

void setup() {
  mouse.begin();
}

double last_x = 0;
double last_y = 0;
void loop() {
  const double radius = 500.0;
  const double rotate_per_sec = 2.0;
  double x = cos(2.0 * M_PI * (millis() / 1000.0) * rotate_per_sec) * radius;
  double y = sin(2.0 * M_PI * (millis() / 1000.0) * rotate_per_sec) * radius;
  int16_t dx = x - last_x;
  int16_t dy = y - last_y;
  last_x = x;
  last_y = y;
  mouse.move(dx, dy, 0);
  delay(10);
}
