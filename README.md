# ZQR
A ZScript reimplementation of [QR-canvas](https://github.com/asdfgdhtns/QR-canvas) by [ellie online](https://ellie.online)


## Usage:
Create a qr code object and pass the data you'd like to include:

```
QRCode qr = QRCode.Create("https:www.ellie.online");
```

Once your code is created, you can draw it to the screen in two ways:

1. In the BaseStatusBar.Draw() function, you can use the QR code object to draw the QR code directly to the screen:
```
override void Draw(int state, double TicFrac)
{ 
    ...
    // Draw the QR code
    qr.DrawBaseStatusBar();
    ...
}
```

2. Alternatively, you can draw the QR code on a Canvas Texture. First, you must define your texture in ANIMDEFS, then you can pass the name of the texture to the DrawCanvasTexture function:
```
    ...
    // Draw the QR code to a texture
    qr.DrawCanvasTexture("MyQRCodeTexture");
    ...
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
