# ZQR
A ZScript reimplementation of [QR-canvas](https://github.com/asdfgdhtns/QR-canvas) by [ellie online](https://ellie.online)


## Usage:
Create a qr code object and pass the data you'd like to include:

```
QRCode qr = QRCode.Create("https:www.ellie.online");
```

In the BaseStatusBar.Draw() function, you can use the QR code object to draw the QR code:
```
override void Draw(int state, double TicFrac)
{ 
    ...
    // Draw the QR code
    qr.Draw();
    ...
}
```


## Parameters:
All params are optional for now; default values are hopefully reasonable
### QR Code:
```
string message:            The data you'd like to encode in the QR code
int errorCorrectionLevel:  0 = L, 1 = M, 2 = Q, 3 = H
bool scrambleUnusedBits:   If true, scramble the graphics during init so that they don't have a checkerboard pattern
```
### Draw function:
```
color bgColor:  Background color of the QR code, MUST be defined as a 4-part color in ARGB format, i.e. color(255, 0, 0, 0)
color fgColor:  Foreground color of the QR code, MUST be defined as a 4-part color in ARGB format, i.e. color(255, 255, 255, 255)
int scalar:     Size of the dots in pixels
int xOffset:    X offset of the QR code
int yOffset:    Y offset of the QR code
int flags:      Drawing flags, defaults to screen center
```