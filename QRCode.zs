//                ███████╗ ██████╗ ██████╗          //
//               ╚══███╔╝██╔═══██╗██╔══██╗          //
//                ███╔╝ ██║   ██║██████╔╝           //
//              ███╔╝  ██║▄▄ ██║██╔══██╗            //
//            ███████╗╚██████╔╝██║  ██║             //
//           ╚══════╝ ╚══▀▀═╝ ╚═╝  ╚═╝              //

// Based on https://github.com/asdfgdhtns/QR-canvas //
//               Version 1, Jan 8 2025              //
//            Visit https://ellie.online            //

class QRCode ui
{
    int scalar;     // size of dots in pixels
    int BORDER;     // Size of the quiet area
    int SIZE;       // Overall size of the QR code

    int errorCorrectionLevel;   // 0 = L, 1 = M, 2 = Q, 3 = H
    int mask;
    string message;
    bool dotArray[37][37];
    int formatINT;
    int nDatawords;             // number of data words
    int nECwords;               // number of error correction words
    Array<int> codeWords;       // nDatawords + nECwords
    bool scrambleUnusedBits;    // If true, scramble the graphics during init so that they don't have a checkerboard pattern

    static QRCode Create(
        string message, 
        int errorCorrectionLevel = 1, 
        bool scrambleUnusedBits = True
    ) {
        let qr = new("QRCode");

        qr.message = message;
        qr.errorCorrectionLevel = errorCorrectionLevel;
        qr.scrambleUnusedBits = scrambleUnusedBits;

        qr.Init();
        return qr;
    }

    void Init()
    {
        // errorCorrectionLevel = 1;
        
        // message = "https://sy.nchroni.city/fstats?data=12345678901234567890123456789012345678901234567890";
        // message = "https://www.ellie.online";
        
        nDatawords = 108;
        nECwords = 26;

        codeWords.Resize(nDatawords + nECwords);

				if (scrambleUnusedBits)
				{
	        // Initialize codeWords array with random data
	        for (int i = 0; i < 134; i++)
	        {
	            codeWords[i] = Random(0, 255);
	        }
				}

        // console.Printf("Message: "..message);

        // Draw alignment squares & timing pattern
        drawBigAlignment(0, 0);
        drawBigAlignment(0, 30);
        drawBigAlignment(30, 0);
        drawSmallAlignment(28, 28);
        drawTiming();

        // blitData();
        // maskData();
        // readData();

        calcData();
        calcErrorCorrection();
        blitData();
        calcFormat();
        drawFormat();
        maskData();
    }

    void drawBigAlignment(int x, int y)
    {
        // Prints a big alignment square to dot array at x, y
        for (int a = 0; a < 7; a++)
        {
            dotArray[x + a][y] = true;
            dotArray[x + a][y + 6] = true;
            dotArray[x][y + a] = true;
            dotArray[x + 6][y + a] = true;
        }

        for (int a = 2; a < 5; a++)
        {
            for (int b = 2; b < 5; b++)
            {
                dotArray[x + a][y + b] = true;
            }
        }
    }

    void drawSmallAlignment(int x, int y)
    {
        // Prints a small alignment square to dot array at x, y
				dotArray[x][y]=True
        dotArray[x + 1][y] = true;
        dotArray[x + 2][y] = true;
        dotArray[x + 3][y] = true;
        dotArray[x + 4][y] = true;
        dotArray[x][y + 4] = true;
        dotArray[x + 1][y + 4] = true;
        dotArray[x + 2][y + 4] = true;
        dotArray[x + 3][y + 4] = true;
        dotArray[x + 4][y + 4] = true;
        dotArray[x][y + 1] = true;
        dotArray[x][y + 2] = true;
        dotArray[x][y + 3] = true;
        dotArray[x + 4][y + 1] = true;
        dotArray[x + 4][y + 2] = true;
        dotArray[x + 4][y + 3] = true;
        dotArray[x + 2][y + 2] = true;
    }

    void drawTiming()
    {
        // Prints timing pattern to dot array
        // for (int i in range(8,29,2))
        for (int i; i < dotArray.Size(); i++)
        {
            // Check if dot is in range(8, 29, 2)
            if (i >= 8 && i <= 29 && i % 2 == 0)
            {
                dotArray[i][6] = true;
                dotArray[6][i] = true;
            }
        }
        dotArray[8][29] = True;
    }

    void calcFormat()
    {
        formatINT = errorCorrectionLevel << 13;
        formatINT |= (mask << 10);

        let r = formatINT;
        for (int a = 4; a >= 0; a --)
        {
            if (r & (1 << a + 10))
            {
                r ^= (1335 << a);
            }
        }

        formatINT |= r;
        formatINT ^= 21522;

        // console.Printf("formatINT: "..formatINT);
    }

    void drawFormat()
    {
        // Draw the format int bits to the dot array
        int fp[2][2][15];
        // lol
        fp[0][0][0] = 8;
        fp[0][0][1] = 8;
        fp[0][0][2] = 8;
        fp[0][0][3] = 8;
        fp[0][0][4] = 8;
        fp[0][0][5] = 8;
        fp[0][0][6] = 8;
        fp[0][0][7] = 8;
        fp[0][0][8] = 7;
        fp[0][0][9] = 5;
        fp[0][0][10] = 4;
        fp[0][0][11] = 3;
        fp[0][0][12] = 2;
        fp[0][0][13] = 1;
        fp[0][0][14] = 0;

        fp[0][1][0] = 0;
        fp[0][1][1] = 1;
        fp[0][1][2] = 2;
        fp[0][1][3] = 3;
        fp[0][1][4] = 4;
        fp[0][1][5] = 5;
        fp[0][1][6] = 7;
        fp[0][1][7] = 8;
        fp[0][1][8] = 8;
        fp[0][1][9] = 8;
        fp[0][1][10] = 8;
        fp[0][1][11] = 8;
        fp[0][1][12] = 8;
        fp[0][1][13] = 8;
        fp[0][1][14] = 8;

        fp[1][0][0] = 36;
        fp[1][0][1] = 35;
        fp[1][0][2] = 34;
        fp[1][0][3] = 33;
        fp[1][0][4] = 32;
        fp[1][0][5] = 31;
        fp[1][0][6] = 30;
        fp[1][0][7] = 29;
        fp[1][0][8] = 8;
        fp[1][0][9] = 8;
        fp[1][0][10] = 8;
        fp[1][0][11] = 8;
        fp[1][0][12] = 8;
        fp[1][0][13] = 8;
        fp[1][0][14] = 8;

        fp[1][1][0] = 8;
        fp[1][1][1] = 8;
        fp[1][1][2] = 8;
        fp[1][1][3] = 8;
        fp[1][1][4] = 8;
        fp[1][1][5] = 8;
        fp[1][1][6] = 8;
        fp[1][1][7] = 8;
        fp[1][1][8] = 30;
        fp[1][1][9] = 31;
        fp[1][1][10] = 32;
        fp[1][1][11] = 33;
        fp[1][1][12] = 34;
        fp[1][1][13] = 35;
        fp[1][1][14] = 36;

        for (int a = 14; a >= 0; a--)
        {
            // console.Printf("a: "..a.." formatINT: "..formatINT.." bit: "..(1 << a).." result: "..(formatINT & (1 << a)));
            if (formatINT & (1 << a))
            {
                dotArray[fp[0][0][a]][fp[0][1][a]] = true;
                dotArray[fp[1][0][a]][fp[1][1][a]] = true;
            }
            else
            {
                dotArray[fp[0][0][a]][fp[0][1][a]] = false;
                dotArray[fp[1][0][a]][fp[1][1][a]] = false;
            }
        }
    }

    bool isDataSpot(int x, int y)
    {
        // Returns true if pixel x, y in the dot array holds message data
        if (x == 6 || y == 6) return False; // Pixel is on the timing pattern or calibration square
        if (x < 9 && y < 9) return False;   // Pixel is on calibration square or format in the top left corner
        if (x < 9 && y > 28) return False;  // Pixel is on calibration square or format in the bottom left corner
        if (x > 28 && y < 9) return False;  // Pixel is on calibration square or format in the top right corner

        if (x > 27 && y > 27 && x < 33 && y < 33) return False; // Pixel is on small calibration square
        
        if (x < 0) return False;
        if (y < 0) return False;

        if (x > 36) return False;
        if (y > 36) return False;

        return True;
    }



    // Calc & Add Data
    int addData(int value, int bits, int cPos)
    {
        // Adds data to codeWords array
        for (int i = 0; i < bits; i++)                      // for each bit in value
        {
            codeWords[cPos >> 3] |= 128 >> (cPos & 7);      // Set the bit in the current byte
            if (value & (1 << bits - i - 1) == False)       // If the bit in value is 0
            {
                codeWords[cPos >> 3] ^= 128 >> (cPos & 7);  // Set the bit in the current byte to 0
            }
            cPos++;
        }
        // console.Printf("value: "..value.." bits: "..bits.." cPos: "..cPos);
        return cPos;
    }

    void calcData()
    {
        // Fills codeWords array with data from message string
        int cPos = 0;   // Current position in codeWords array

        // Add mode indicator
        cPos = addData(4, 4, cPos);

        // Add character count indicator
        cPos = addData(message.Length(), 8, cPos);   // Using string.Length() instead of string.CodePointCount() because it returns bytes instead of number of characters

        // Add message data
        int chr, next;
        for (int i = 0; i < message.Length();)
        {
            [chr, next] = message.GetNextCodePoint(i);

            // console.Printf("chr: "..chr.." letter: "..message.Mid(i, next - 1));
            cPos = addData(chr, 8, cPos);

            i = next;
        }

        // Add terminator and pad with zeros
        cPos = addData(0, 4, cPos);

        for (int i; i < codeWords.Size(); i++)
        {
            // console.Printf("codeWords["..i.."]: "..codeWords[i]);
        }

    }
    // End Calc & Add Data


    // Error correction
    int prod(int n1, int n2)
    {
        // Multiplies two numbers in GF(2^8)
        int p = 0;

        for (int i; i < 8; i++)
        {
            if (n1 & (1 << i))
            {
                for (int j; j < 8; j++)
                {
                    if (n2 & (1 << j))
                    {
                        p ^= 1 << (i + j);
                    }
                }
            }
        }

        for (int i = 14; i > 7; i--)
        {
            if (p & (1 << i))
            {
                p ^= 285 << (i - 8);
            }
        }

        return p;
    }

    void calcCGP(Array<int> CGP)
    {
        Array<int> tp;
        tp.Resize(27);

        CGP[0] = 1;
        CGP[1] = 1;
        tp[0] = 1;
        tp[1] = 2;

        for (int i = 1; i < nECwords; i++)
        {
            // multiply the current generator polynomial by (x + 2)
            // nts: this is a reimplementation of polyProd() from the original code
            Array<int> pptp;
            pptp.Resize(27);
            for (int k = 0; k < i + 1; k++)
            {
                if (CGP[k])
                {
                    for (int l = 0; l < 1 + 1; l++)
                    {
                        if (tp[l])
                        {
                            pptp[k + l] ^= prod(CGP[k], tp[l]);
                        }
                    }
                }
            }

            CGP = pptp;
            tp[1] = prod(tp[1], 2);
        }
    }
    
    void calcErrorCorrection()
    {
        // Calculates and adds Error Correction bytes to codeWords array
        Array<int> CGP; // Generator polynomial
        CGP.Resize(27);

        int R[109];     // 109 is number of data code words + 1

        calcCGP(CGP);
        // for (int i; i < CGP.Size(); i++)
        // {
        //     console.Printf("CGP["..i.."]: "..CGP[i]);
        // }

        for (int i; i < nDatawords; i++)
        {
            // console.Printf("codeWords["..i.."]: "..codeWords[i]);

            R[i] = codeWords[i];
        }

        R[nDatawords] = 0;

        for (int i; i < nDatawords; i++)
        {
            let c = R[0];

            for (int j; j < nECwords + 1; j++)
            {
                if (j < nECwords)
                {
                    R[j] = R[j + 1] ^ prod(CGP[j+1], c);
                } else {
                    if (i + nECwords < nDatawords)
                    {
                        R[j] = codeWords[i + nECwords + 1];
                    } else {
                        R[j] = 0;
                    }
                }
            }
        }

        for (int i; i < nECwords; i++)
        {
            // console.Printf("R["..i.."]: "..R[i]);
            codeWords[nDatawords + i] = R[i];
        }
    }
    // End error correction


    void blitData()
    {
        // Prints codeWords array to dot array
        int x, y, p, src, pByte, pBit;
        x = 36;
        y = 36;

        for (int i; i < codeWords.Size(); i++)
        {
            // console.Printf("codeWords["..i.."]: "..codeWords[i]);
        }

        while (p < 4)
        {
            // console.printf("pbyte: "..pByte.." pbit: "..pBit.." x: "..x.." y: "..y.." isDataSpot: "..isDataSpot(x, y));
            if (isDataSpot(x, y))
            {
                if (src == 0)                                   // If we're writing data (not error correction)
                {
                    dotArray[x][y] = False;                     // Set the dot to false
                    if (codeWords[pByte] & (128 >> pBit))       // If the value of the current byte is 1, set the dot to true
                    {
                        dotArray[x][y] = True;
                    }

                    pBit++;                                     // Move to the next bit

                    if (pBit == 8)                                  // If we've reached the end of the byte
                    {
                        pBit = 0;                                   // Reset the bit counter
                        pByte++;                                    // Move to the next byte

                        if (pByte >= nDatawords)                    // If we've reached the end of the data words
                        {
                            pByte = 0;                                  // Reset the byte counter
                            src = 1;                                    // Move to the error correction words
                        }
                    }
                } else {
                    dotArray[x][y] = False;
                    if (codeWords[nDatawords + pByte] & (128 >> pBit))
                    {
                        dotArray[x][y] = True;
                    }

                    pBit++;
                    if (pBit == 8)
                    {
                        pBit = 0;
                        pByte++;

                        if (pByte == nECwords)
                        {
                            p = 4;
                        }
                    }
                }
            }

            switch (p)
            {
                case 0:
                    x -= 1;
                    p = 1;
                    break;
                case 1:
                    x += 1;
                    p = 0;

                    if (y == 0)
                    {
                        x -= 2;
                        if (x == 6) {
                            x -= 1;
                        }
                        p = 2;
                    } else {
                        y -= 1;
                    }
                    break;
                case 2:
                    x -= 1;
                    p = 3;
                    break;
                case 3:
                    x += 1;
                    p = 2;

                    if (y == 36) 
                    {
                        x -= 2;
                        p = 0;
                    } else {
                        y += 1;
                    }
                    break;
            }
        }
    }

    void maskData()
    {
        // Applies the data mask to the dot array
        for (int x; x < 37; x++) {
            for (int y; y < 37; y++) {
                if (isDataSpot(x, y)) { // If we're allowed to write to this spot
                    // console.printf("x: "..x.." y: "..y.." mask: "..mask);
                    switch (mask) {
                        case 0:
                            if (((x+y) & 1) == 0) {
                                dotArray[x][y] = !dotArray[x][y];
                            }
                            break;
                        case 1:
                            if ((y & 1) == 0) {
                                dotArray[x][y] = !dotArray[x][y];   
                            }
                            break;
                        case 2:
                            if ((x % 3) == 0) {
                                dotArray[x][y] = !dotArray[x][y];   
                            }
                            break;
                        case 3:
                            if (((x+y) % 3) == 0) {
                                dotArray[x][y] = !dotArray[x][y];   
                            }
                            break;
                        case 4:
                            if (((int(floor(x/3) + floor(y/2))) & 1) == 0) {
                                dotArray[x][y] = !dotArray[x][y];   
                            }
                            break;
                        case 5:
                            if (((x*y) & 1) + ((x*y) % 3) == 0) {
                                dotArray[x][y] = !dotArray[x][y];   
                            }
                            break;
                        case 6:
                            if (((((x*y) & 1) + ((x*y) % 3)) & 1) == 0) {
                                dotArray[x][y] = !dotArray[x][y];   
                            }
                            break;
                        case 7:
                            if (((((x+y) % 2) + ((x*y) % 3)) % 2) == 0) {
                                dotArray[x][y] = !dotArray[x][y];   
                            }
                            break;
                    }
                }
            }
        }
    }

    void readData()
    {
        // Read the dot array and convert it to bytes to store in codeWords array
        // TODO: this is busted, but not necessary for core functionality
        int x, y, p, src, pByte, pBit;

        x = 36;
        y = 36;

        while (p < 4)
        {
            if (isDataSpot(x, y))
            {
                codeWords[pByte] |= (128 >> pBit);
                if (dotArray[x][y] = False)
                {
                    codeWords[pByte] ^= (128 >> pBit);
                }
                pBit++;

                if (pBit == 8)
                {
                    pBit = 0;
                    pByte++;

                    if (pByte == nDatawords)
                    {
                        pByte = 0;
                        p = 4;
                    }
                }
            }

            switch(p)
            {
                case 0:
                    x -= 1;
                    p = 1;
                    break;
                case 1:
                    x += 1;
                    p = 0;

                    if (y == 0)
                    {
                        x -= 2;
                        if (x == 6)
                        {
                            x -= 1;
                        }
                        p = 2;
                    } else {
                        y -= 1;
                    }
                    break;
                case 2:
                    x -= 1;
                    p = 3;
                    break;
                case 3:
                    x += 1;
                    p = 2;

                    if (y == 36)
                    {
                        x -= 2;
                        p = 0;
                    } else {
                        y += 1;
                    }
                    break;
            }
        }
    }


    void DrawBaseStatusBar(
        color fgColor = color(255, 0, 0, 0), 
        color bgColor = color(255, 255, 255, 255), 
        int scalar = 3, 
        int xOffset = 0, 
        int yOffset = 0, 
        int flags = BaseStatusBar(StatusBar).DI_SCREEN_CENTER       // Defaults to screen center
    ) {
        // Fill(color(255, 255, 255, 255), 0., 0., scalar+ BORDER, scalar+ BORDER, DI_SCREEN_CENTER);

        // Get status bar visibility
        let sb = BaseStatusBar(StatusBar);
        if (!sb) return;

        // scalar = 3;
        BORDER = scalar * 2;
        SIZE = 2 * BORDER + scalar * 37;

        // Draw the quiet area shhhshshshh
        sb.Fill(bgColor, xOffset - (SIZE / 2), yOffset - (SIZE / 2), SIZE, SIZE, flags);

        // Draw the QR code based on the dot pattern
        for (int x = 0; x < 37; x++)
        {
            for (int y = 0; y < 37; y++)
            {
                if (dotArray[x][y])
                {
                    sb.Fill(fgColor, xOffset + (x * scalar + BORDER) - (SIZE / 2), yOffset + (y * scalar + BORDER) - (SIZE / 2), scalar, scalar, flags);
                } else {
                    sb.Fill(bgColor, xOffset + (x * scalar + BORDER) - (SIZE / 2), yOffset + (y * scalar + BORDER) - (SIZE / 2), scalar, scalar, flags);
                }
            }
        }
    }

    void DrawCanvasTexture(
        string texture,
        string backgroundTexture = "",
        color fgColor = color(255, 0, 0, 0), 
        color bgColor = color(255, 255, 255, 255), 
        float fgAlpha = 1.0,
        float bgAlpha = 1.0,
        int scalar = 1, 
        int xOffset = 0, 
        int yOffset = 0,
        int styleFlags = STYLE_Normal
    ) {
        if (texture == "") return;
        
        // Make sure texture exists
        TextureID texID = TexMan.CheckForTexture(texture);
        if (!texID) return;

        // Create canvas from texture (if this fails, make sure you have a CanvasTexture defined in ANIMDEFS)
        Canvas canvas = TexMan.GetCanvas(texture);
        if (canvas == null) return;

        // Get width and height from CanvasTexture
        let [w, h] = TexMan.GetSize(texID);

        // Draw background texture if exists
        let bgTex = TexMan.CheckForTexture(backgroundTexture);
        if (bgTex) {
            canvas.DrawTexture(bgTex, false, 0, 0);
        } else {
            console.Printf("Error in ZQR.DrawCanvasTexture('" .. texture .. "'): Background texture '" .. backgroundTexture .. "' not found, drawing QR code on a blank canvas");
        }

        // Fit qr code to the center of the texture
        // TODO: add a flag for this
        xOffset += w / 4;
        yOffset += h / 4;
    
        BORDER = scalar * 2;
        SIZE = BORDER + (scalar * 37);

        // Draw the quiet area shhhshshshh
        canvas.Dim( // Left
            bgColor,
            bgAlpha,
            xOffset, yOffset + scalar,
            BORDER / 2, SIZE - scalar,
            styleFlags
        );
        canvas.Dim( // Right
            bgColor,
            bgAlpha,
            xOffset + SIZE - (BORDER / 2), yOffset + scalar,
            BORDER / 2, SIZE - scalar,
            styleFlags
        );
        canvas.Dim( // Top
            bgColor,
            bgAlpha,
            xOffset, yOffset,
            SIZE, BORDER / 2,
            styleFlags
        );
        canvas.Dim( // Bottom
            bgColor,
            bgAlpha,
            xOffset + scalar, yOffset + SIZE - (BORDER / 2),
            SIZE - (scalar * 2), BORDER / 2,
            styleFlags
        );


        // Draw the QR code based on the dot pattern
        for (int x = 0; x < 37; x++)
        {
            for (int y = 0; y < 37; y++)
            {
                if (dotArray[x][y])
                {
                    canvas.Dim(
                        fgColor,
                        fgAlpha,
                        xOffset + (x * scalar + (BORDER / 2)),
                        yOffset + (y * scalar + (BORDER / 2)),
                        scalar, scalar,
                        styleFlags
                    );
                } else {
                    canvas.Dim(
                        bgColor,
                        bgAlpha,
                        xOffset + (x * scalar + (BORDER / 2)),
                        yOffset + (y * scalar + (BORDER / 2)),
                        scalar, scalar,
                        styleFlags
                    );
                }
            }
        }
    }
}