package starling.display.graphics
{
   public class RoundedRectangle extends starling.display.graphics.GraphicRenderer
   {
      
      private static var halfWidth:Number;
      
      private static var halfHeight:Number;
      
      private static var tlr:Number;
      
      private static var trr:Number;
      
      private static var blr:Number;
      
      private static var brr:Number;
      
      private static var numVertices:int;
      
      private static var i:int;
      
      private static var radians:Number;
      
      private static var sin:Number;
      
      private static var cos:Number;
      
      private static var xPos:Number;
      
      private static var yPos:Number;
      
      private static var vertexCount:uint;
      
      private static var indicesCount:uint;
      
      private static var strokePointCount:uint;
       
      
      private const DEGREES_TO_RADIANS:Number = 0.017453292519943295;
      
      private var _width:Number;
      
      private var _height:Number;
      
      private var _topLeftRadius:Number;
      
      private var _topRightRadius:Number;
      
      private var _bottomLeftRadius:Number;
      
      private var _bottomRightRadius:Number;
      
      private var strokePoints:Vector.<Number>;
      
      private var _radiusPrecision:uint;
      
      public function RoundedRectangle(param1:Number = 100, param2:Number = 100, param3:Number = 10, param4:Number = 10, param5:Number = 10, param6:Number = 10, param7:uint = 20)
      {
         super();
         this.width = param1;
         this.height = param2;
         this.topLeftRadius = param3;
         this.topRightRadius = param4;
         this.bottomLeftRadius = param5;
         this.bottomRightRadius = param6;
         this.radiusPrecision = param7;
         this.strokePoints = new Vector.<Number>();
         vertices = new Vector.<Number>();
         indices = new Vector.<uint>();
      }
      
      public function get radiusPrecision() : Number
      {
         return this._radiusPrecision;
      }
      
      public function set radiusPrecision(param1:Number) : void
      {
         this._radiusPrecision = param1 < 3 ? 3 : uint(param1);
         setGeometryInvalid();
      }
      
      override public function set width(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._width = param1;
         maxBounds.x = this._width;
         setGeometryInvalid();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._height = param1;
         maxBounds.y = this._height;
         setGeometryInvalid();
      }
      
      public function get cornerRadius() : Number
      {
         return this._topLeftRadius;
      }
      
      public function set cornerRadius(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._topLeftRadius = this._topRightRadius = this._bottomLeftRadius = this._bottomRightRadius = param1;
         setGeometryInvalid();
      }
      
      public function get topLeftRadius() : Number
      {
         return this._topLeftRadius;
      }
      
      public function set topLeftRadius(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._topLeftRadius = param1;
         setGeometryInvalid();
      }
      
      public function get topRightRadius() : Number
      {
         return this._topRightRadius;
      }
      
      public function set topRightRadius(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._topRightRadius = param1;
         setGeometryInvalid();
      }
      
      public function get bottomLeftRadius() : Number
      {
         return this._bottomLeftRadius;
      }
      
      public function set bottomLeftRadius(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._bottomLeftRadius = param1;
         setGeometryInvalid();
      }
      
      public function get bottomRightRadius() : Number
      {
         return this._bottomRightRadius;
      }
      
      public function set bottomRightRadius(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : param1;
         this._bottomRightRadius = param1;
         setGeometryInvalid();
      }
      
      public function getStrokePoints() : Vector.<Number>
      {
         validateNow();
         return this.strokePoints;
      }
      
      override protected function buildGeometry() : void
      {
         this.strokePoints.length = 0;
         vertices.length = 0;
         indices.length = 0;
         halfWidth = this._width * 0.5;
         halfHeight = this._height * 0.5;
         tlr = Math.min(halfWidth,halfHeight,this._topLeftRadius);
         trr = Math.min(halfWidth,halfHeight,this._topRightRadius);
         blr = Math.min(halfWidth,halfHeight,this._bottomLeftRadius);
         brr = Math.min(halfWidth,halfHeight,this._bottomRightRadius);
         vertexCount = 0;
         var _loc1_:* = vertexCount++;
         vertices[_loc1_] = tlr;
         var _loc2_:* = vertexCount++;
         vertices[_loc2_] = 0;
         var _loc3_:* = vertexCount++;
         vertices[_loc3_] = 0;
         var _loc4_:*;
         vertices[_loc4_ = vertexCount++] = 1;
         var _loc5_:*;
         vertices[_loc5_ = vertexCount++] = 1;
         var _loc6_:*;
         vertices[_loc6_ = vertexCount++] = 1;
         var _loc7_:*;
         vertices[_loc7_ = vertexCount++] = 1;
         var _loc8_:*;
         vertices[_loc8_ = vertexCount++] = tlr / this._width;
         var _loc9_:*;
         vertices[_loc9_ = vertexCount++] = 0;
         var _loc10_:*;
         vertices[_loc10_ = vertexCount++] = tlr;
         var _loc11_:*;
         vertices[_loc11_ = vertexCount++] = tlr;
         var _loc12_:*;
         vertices[_loc12_ = vertexCount++] = 0;
         var _loc13_:*;
         vertices[_loc13_ = vertexCount++] = 1;
         var _loc14_:*;
         vertices[_loc14_ = vertexCount++] = 1;
         var _loc15_:*;
         vertices[_loc15_ = vertexCount++] = 1;
         var _loc16_:*;
         vertices[_loc16_ = vertexCount++] = 1;
         var _loc17_:*;
         vertices[_loc17_ = vertexCount++] = tlr / this._width;
         var _loc18_:*;
         vertices[_loc18_ = vertexCount++] = tlr / this._height;
         var _loc19_:*;
         vertices[_loc19_ = vertexCount++] = 0;
         var _loc20_:*;
         vertices[_loc20_ = vertexCount++] = tlr;
         var _loc21_:*;
         vertices[_loc21_ = vertexCount++] = 0;
         var _loc22_:*;
         vertices[_loc22_ = vertexCount++] = 1;
         var _loc23_:*;
         vertices[_loc23_ = vertexCount++] = 1;
         var _loc24_:*;
         vertices[_loc24_ = vertexCount++] = 1;
         var _loc25_:*;
         vertices[_loc25_ = vertexCount++] = 1;
         var _loc26_:*;
         vertices[_loc26_ = vertexCount++] = 0;
         var _loc27_:*;
         vertices[_loc27_ = vertexCount++] = tlr / this._height;
         var _loc28_:*;
         vertices[_loc28_ = vertexCount++] = this._width - trr;
         var _loc29_:*;
         vertices[_loc29_ = vertexCount++] = 0;
         var _loc30_:*;
         vertices[_loc30_ = vertexCount++] = 0;
         var _loc31_:*;
         vertices[_loc31_ = vertexCount++] = 1;
         var _loc32_:*;
         vertices[_loc32_ = vertexCount++] = 1;
         var _loc33_:*;
         vertices[_loc33_ = vertexCount++] = 1;
         var _loc34_:*;
         vertices[_loc34_ = vertexCount++] = 1;
         var _loc35_:*;
         vertices[_loc35_ = vertexCount++] = (this._width - trr) / this._width;
         var _loc36_:*;
         vertices[_loc36_ = vertexCount++] = 0;
         var _loc37_:*;
         vertices[_loc37_ = vertexCount++] = this._width - trr;
         var _loc38_:*;
         vertices[_loc38_ = vertexCount++] = trr;
         var _loc39_:*;
         vertices[_loc39_ = vertexCount++] = 0;
         var _loc40_:*;
         vertices[_loc40_ = vertexCount++] = 1;
         var _loc41_:*;
         vertices[_loc41_ = vertexCount++] = 1;
         var _loc42_:*;
         vertices[_loc42_ = vertexCount++] = 1;
         var _loc43_:*;
         vertices[_loc43_ = vertexCount++] = 1;
         var _loc44_:*;
         vertices[_loc44_ = vertexCount++] = (this._width - trr) / this._width;
         var _loc45_:*;
         vertices[_loc45_ = vertexCount++] = trr / this._height;
         var _loc46_:*;
         vertices[_loc46_ = vertexCount++] = this._width;
         var _loc47_:*;
         vertices[_loc47_ = vertexCount++] = trr;
         var _loc48_:*;
         vertices[_loc48_ = vertexCount++] = 0;
         var _loc49_:*;
         vertices[_loc49_ = vertexCount++] = 1;
         var _loc50_:*;
         vertices[_loc50_ = vertexCount++] = 1;
         var _loc51_:*;
         vertices[_loc51_ = vertexCount++] = 1;
         var _loc52_:*;
         vertices[_loc52_ = vertexCount++] = 1;
         var _loc53_:*;
         vertices[_loc53_ = vertexCount++] = 1;
         var _loc54_:*;
         vertices[_loc54_ = vertexCount++] = trr / this._height;
         var _loc55_:*;
         vertices[_loc55_ = vertexCount++] = blr;
         var _loc56_:*;
         vertices[_loc56_ = vertexCount++] = this._height;
         var _loc57_:*;
         vertices[_loc57_ = vertexCount++] = 0;
         var _loc58_:*;
         vertices[_loc58_ = vertexCount++] = 1;
         var _loc59_:*;
         vertices[_loc59_ = vertexCount++] = 1;
         var _loc60_:*;
         vertices[_loc60_ = vertexCount++] = 1;
         var _loc61_:*;
         vertices[_loc61_ = vertexCount++] = 1;
         var _loc62_:*;
         vertices[_loc62_ = vertexCount++] = blr / this._width;
         var _loc63_:*;
         vertices[_loc63_ = vertexCount++] = 1;
         var _loc64_:*;
         vertices[_loc64_ = vertexCount++] = blr;
         var _loc65_:*;
         vertices[_loc65_ = vertexCount++] = this._height - blr;
         var _loc66_:*;
         vertices[_loc66_ = vertexCount++] = 0;
         var _loc67_:*;
         vertices[_loc67_ = vertexCount++] = 1;
         var _loc68_:*;
         vertices[_loc68_ = vertexCount++] = 1;
         var _loc69_:*;
         vertices[_loc69_ = vertexCount++] = 1;
         var _loc70_:*;
         vertices[_loc70_ = vertexCount++] = 1;
         var _loc71_:*;
         vertices[_loc71_ = vertexCount++] = blr / this._width;
         var _loc72_:*;
         vertices[_loc72_ = vertexCount++] = (this._height - blr) / this._height;
         var _loc73_:*;
         vertices[_loc73_ = vertexCount++] = 0;
         var _loc74_:*;
         vertices[_loc74_ = vertexCount++] = this._height - blr;
         var _loc75_:*;
         vertices[_loc75_ = vertexCount++] = 0;
         var _loc76_:*;
         vertices[_loc76_ = vertexCount++] = 1;
         var _loc77_:*;
         vertices[_loc77_ = vertexCount++] = 1;
         var _loc78_:*;
         vertices[_loc78_ = vertexCount++] = 1;
         var _loc79_:*;
         vertices[_loc79_ = vertexCount++] = 1;
         var _loc80_:*;
         vertices[_loc80_ = vertexCount++] = 0;
         var _loc81_:*;
         vertices[_loc81_ = vertexCount++] = (this._height - blr) / this._height;
         var _loc82_:*;
         vertices[_loc82_ = vertexCount++] = this._width - brr;
         var _loc83_:*;
         vertices[_loc83_ = vertexCount++] = this._height;
         var _loc84_:*;
         vertices[_loc84_ = vertexCount++] = 0;
         var _loc85_:*;
         vertices[_loc85_ = vertexCount++] = 1;
         var _loc86_:*;
         vertices[_loc86_ = vertexCount++] = 1;
         var _loc87_:*;
         vertices[_loc87_ = vertexCount++] = 1;
         var _loc88_:*;
         vertices[_loc88_ = vertexCount++] = 1;
         var _loc89_:*;
         vertices[_loc89_ = vertexCount++] = (this._width - brr) / this._width;
         var _loc90_:*;
         vertices[_loc90_ = vertexCount++] = 1;
         var _loc91_:*;
         vertices[_loc91_ = vertexCount++] = this._width - brr;
         var _loc92_:*;
         vertices[_loc92_ = vertexCount++] = this._height - brr;
         var _loc93_:*;
         vertices[_loc93_ = vertexCount++] = 0;
         var _loc94_:*;
         vertices[_loc94_ = vertexCount++] = 1;
         var _loc95_:*;
         vertices[_loc95_ = vertexCount++] = 1;
         var _loc96_:*;
         vertices[_loc96_ = vertexCount++] = 1;
         var _loc97_:*;
         vertices[_loc97_ = vertexCount++] = 1;
         var _loc98_:*;
         vertices[_loc98_ = vertexCount++] = (this._width - brr) / this._width;
         var _loc99_:*;
         vertices[_loc99_ = vertexCount++] = (this._height - brr) / this._height;
         var _loc100_:*;
         vertices[_loc100_ = vertexCount++] = this._width;
         var _loc101_:*;
         vertices[_loc101_ = vertexCount++] = this._height - brr;
         var _loc102_:*;
         vertices[_loc102_ = vertexCount++] = 0;
         var _loc103_:*;
         vertices[_loc103_ = vertexCount++] = 1;
         var _loc104_:*;
         vertices[_loc104_ = vertexCount++] = 1;
         var _loc105_:*;
         vertices[_loc105_ = vertexCount++] = 1;
         var _loc106_:*;
         vertices[_loc106_ = vertexCount++] = 1;
         var _loc107_:*;
         vertices[_loc107_ = vertexCount++] = 1;
         var _loc108_:*;
         vertices[_loc108_ = vertexCount++] = (this._height - brr) / this._height;
         indicesCount = 0;
         var _loc109_:*;
         indices[_loc109_ = indicesCount++] = 0;
         var _loc110_:*;
         indices[_loc110_ = indicesCount++] = 3;
         var _loc111_:*;
         indices[_loc111_ = indicesCount++] = 1;
         var _loc112_:*;
         indices[_loc112_ = indicesCount++] = 1;
         var _loc113_:*;
         indices[_loc113_ = indicesCount++] = 3;
         var _loc114_:*;
         indices[_loc114_ = indicesCount++] = 4;
         var _loc115_:*;
         indices[_loc115_ = indicesCount++] = 2;
         var _loc116_:*;
         indices[_loc116_ = indicesCount++] = 1;
         var _loc117_:*;
         indices[_loc117_ = indicesCount++] = 8;
         var _loc118_:*;
         indices[_loc118_ = indicesCount++] = 8;
         var _loc119_:*;
         indices[_loc119_ = indicesCount++] = 1;
         var _loc120_:*;
         indices[_loc120_ = indicesCount++] = 7;
         var _loc121_:*;
         indices[_loc121_ = indicesCount++] = 7;
         var _loc122_:*;
         indices[_loc122_ = indicesCount++] = 1;
         var _loc123_:*;
         indices[_loc123_ = indicesCount++] = 4;
         var _loc124_:*;
         indices[_loc124_ = indicesCount++] = 7;
         var _loc125_:*;
         indices[_loc125_ = indicesCount++] = 4;
         var _loc126_:*;
         indices[_loc126_ = indicesCount++] = 10;
         var _loc127_:*;
         indices[_loc127_ = indicesCount++] = 10;
         var _loc128_:*;
         indices[_loc128_ = indicesCount++] = 4;
         var _loc129_:*;
         indices[_loc129_ = indicesCount++] = 5;
         var _loc130_:*;
         indices[_loc130_ = indicesCount++] = 10;
         var _loc131_:*;
         indices[_loc131_ = indicesCount++] = 5;
         var _loc132_:*;
         indices[_loc132_ = indicesCount++] = 11;
         var _loc133_:*;
         indices[_loc133_ = indicesCount++] = 6;
         var _loc134_:*;
         indices[_loc134_ = indicesCount++] = 7;
         var _loc135_:*;
         indices[_loc135_ = indicesCount++] = 10;
         var _loc136_:*;
         indices[_loc136_ = indicesCount++] = 6;
         var _loc137_:*;
         indices[_loc137_ = indicesCount++] = 10;
         var _loc138_:*;
         indices[_loc138_ = indicesCount++] = 9;
         numVertices = 12;
         strokePointCount = 0;
         var _loc139_:*;
         this.strokePoints[_loc139_ = strokePointCount++] = 0;
         var _loc140_:*;
         this.strokePoints[_loc140_ = strokePointCount++] = tlr;
         if(tlr > 0)
         {
            i = 0;
            while(i < this._radiusPrecision)
            {
               radians = (i + 1) / (this._radiusPrecision + 1) * Math.PI * 0.5;
               radians += Math.PI * 1.5;
               sin = Math.sin(radians);
               cos = Math.cos(radians);
               xPos = tlr + sin * tlr;
               yPos = tlr - cos * tlr;
               var _loc141_:*;
               vertices[_loc141_ = vertexCount++] = xPos;
               var _loc142_:*;
               vertices[_loc142_ = vertexCount++] = yPos;
               var _loc143_:*;
               vertices[_loc143_ = vertexCount++] = 0;
               var _loc144_:*;
               vertices[_loc144_ = vertexCount++] = 1;
               var _loc145_:*;
               vertices[_loc145_ = vertexCount++] = 1;
               var _loc146_:*;
               vertices[_loc146_ = vertexCount++] = 1;
               var _loc147_:*;
               vertices[_loc147_ = vertexCount++] = 1;
               var _loc148_:*;
               vertices[_loc148_ = vertexCount++] = xPos / this._width;
               var _loc149_:*;
               vertices[_loc149_ = vertexCount++] = yPos / this._height;
               var _loc150_:*;
               this.strokePoints[_loc150_ = strokePointCount++] = xPos;
               var _loc151_:*;
               this.strokePoints[_loc151_ = strokePointCount++] = yPos;
               ++numVertices;
               if(i == 0)
               {
                  var _loc152_:*;
                  indices[_loc152_ = indicesCount++] = 1;
                  var _loc153_:*;
                  indices[_loc153_ = indicesCount++] = 2;
                  var _loc154_:*;
                  indices[_loc154_ = indicesCount++] = numVertices - 1;
               }
               else
               {
                  indices[_loc152_ = indicesCount++] = 1;
                  indices[_loc153_ = indicesCount++] = numVertices - 2;
                  indices[_loc154_ = indicesCount++] = numVertices - 1;
               }
               if(i == this._radiusPrecision - 1)
               {
                  indices[_loc152_ = indicesCount++] = 1;
                  indices[_loc153_ = indicesCount++] = numVertices - 1;
                  indices[_loc154_ = indicesCount++] = 0;
               }
               ++i;
            }
         }
         this.strokePoints[_loc141_ = strokePointCount++] = tlr;
         this.strokePoints[_loc142_ = strokePointCount++] = 0;
         this.strokePoints[_loc143_ = strokePointCount++] = this._width - trr;
         this.strokePoints[_loc144_ = strokePointCount++] = 0;
         if(trr > 0)
         {
            i = 0;
            while(i < this._radiusPrecision)
            {
               radians = (i + 1) / (this._radiusPrecision + 1) * Math.PI * 0.5;
               sin = Math.sin(radians);
               cos = Math.cos(radians);
               xPos = this._width - trr + sin * trr;
               yPos = trr - cos * trr;
               vertices[_loc145_ = vertexCount++] = xPos;
               vertices[_loc146_ = vertexCount++] = yPos;
               vertices[_loc147_ = vertexCount++] = 0;
               vertices[_loc148_ = vertexCount++] = 1;
               vertices[_loc149_ = vertexCount++] = 1;
               vertices[_loc150_ = vertexCount++] = 1;
               vertices[_loc151_ = vertexCount++] = 1;
               vertices[_loc152_ = vertexCount++] = xPos / this._width;
               vertices[_loc153_ = vertexCount++] = yPos / this._height;
               this.strokePoints[_loc154_ = strokePointCount++] = xPos;
               var _loc155_:*;
               this.strokePoints[_loc155_ = strokePointCount++] = yPos;
               ++numVertices;
               if(i == 0)
               {
                  var _loc156_:*;
                  indices[_loc156_ = indicesCount++] = 4;
                  var _loc157_:*;
                  indices[_loc157_ = indicesCount++] = 3;
                  var _loc158_:*;
                  indices[_loc158_ = indicesCount++] = numVertices - 1;
               }
               else
               {
                  indices[_loc156_ = indicesCount++] = 4;
                  indices[_loc157_ = indicesCount++] = numVertices - 2;
                  indices[_loc158_ = indicesCount++] = numVertices - 1;
               }
               if(i == this._radiusPrecision - 1)
               {
                  indices[_loc156_ = indicesCount++] = 4;
                  indices[_loc157_ = indicesCount++] = numVertices - 1;
                  indices[_loc158_ = indicesCount++] = 5;
               }
               ++i;
            }
         }
         this.strokePoints[_loc145_ = strokePointCount++] = this._width;
         this.strokePoints[_loc146_ = strokePointCount++] = trr;
         this.strokePoints[_loc147_ = strokePointCount++] = this._width;
         this.strokePoints[_loc148_ = strokePointCount++] = this._height - brr;
         if(brr > 0)
         {
            i = 0;
            while(i < this._radiusPrecision)
            {
               radians = (i + 1) / (this._radiusPrecision + 1) * Math.PI * 0.5;
               radians += Math.PI * 0.5;
               sin = Math.sin(radians);
               cos = Math.cos(radians);
               xPos = this._width - brr + sin * brr;
               yPos = this._height - brr - cos * brr;
               vertices[_loc149_ = vertexCount++] = xPos;
               vertices[_loc150_ = vertexCount++] = yPos;
               vertices[_loc151_ = vertexCount++] = 0;
               vertices[_loc152_ = vertexCount++] = 1;
               vertices[_loc153_ = vertexCount++] = 1;
               vertices[_loc154_ = vertexCount++] = 1;
               vertices[_loc155_ = vertexCount++] = 1;
               vertices[_loc156_ = vertexCount++] = xPos / this._width;
               vertices[_loc157_ = vertexCount++] = yPos / this._height;
               this.strokePoints[_loc158_ = strokePointCount++] = xPos;
               var _loc159_:*;
               this.strokePoints[_loc159_ = strokePointCount++] = yPos;
               ++numVertices;
               if(i == 0)
               {
                  var _loc160_:*;
                  indices[_loc160_ = indicesCount++] = 10;
                  var _loc161_:*;
                  indices[_loc161_ = indicesCount++] = 11;
                  var _loc162_:*;
                  indices[_loc162_ = indicesCount++] = numVertices - 1;
               }
               else
               {
                  indices[_loc160_ = indicesCount++] = 10;
                  indices[_loc161_ = indicesCount++] = numVertices - 2;
                  indices[_loc162_ = indicesCount++] = numVertices - 1;
               }
               if(i == this._radiusPrecision - 1)
               {
                  indices[_loc160_ = indicesCount++] = 10;
                  indices[_loc161_ = indicesCount++] = numVertices - 1;
                  indices[_loc162_ = indicesCount++] = 9;
               }
               ++i;
            }
         }
         this.strokePoints[_loc149_ = strokePointCount++] = this._width - brr;
         this.strokePoints[_loc150_ = strokePointCount++] = this._height;
         this.strokePoints[_loc151_ = strokePointCount++] = blr;
         this.strokePoints[_loc152_ = strokePointCount++] = this._height;
         if(blr > 0)
         {
            i = 0;
            while(i < this._radiusPrecision)
            {
               radians = (i + 1) / (this._radiusPrecision + 1) * Math.PI * 0.5;
               radians += Math.PI;
               sin = Math.sin(radians);
               cos = Math.cos(radians);
               xPos = blr + sin * blr;
               yPos = this._height - blr - cos * blr;
               vertices[_loc153_ = vertexCount++] = xPos;
               vertices[_loc154_ = vertexCount++] = yPos;
               vertices[_loc155_ = vertexCount++] = 0;
               vertices[_loc156_ = vertexCount++] = 1;
               vertices[_loc157_ = vertexCount++] = 1;
               vertices[_loc158_ = vertexCount++] = 1;
               vertices[_loc159_ = vertexCount++] = 1;
               vertices[_loc160_ = vertexCount++] = xPos / this._width;
               vertices[_loc161_ = vertexCount++] = yPos / this._height;
               this.strokePoints[_loc162_ = strokePointCount++] = xPos;
               var _loc163_:*;
               this.strokePoints[_loc163_ = strokePointCount++] = yPos;
               ++numVertices;
               if(i == 0)
               {
                  var _loc164_:*;
                  indices[_loc164_ = indicesCount++] = 7;
                  var _loc165_:*;
                  indices[_loc165_ = indicesCount++] = 6;
                  var _loc166_:*;
                  indices[_loc166_ = indicesCount++] = numVertices - 1;
               }
               else
               {
                  indices[_loc164_ = indicesCount++] = 7;
                  indices[_loc165_ = indicesCount++] = numVertices - 2;
                  indices[_loc166_ = indicesCount++] = numVertices - 1;
               }
               if(i == this._radiusPrecision - 1)
               {
                  indices[_loc164_ = indicesCount++] = 7;
                  indices[_loc165_ = indicesCount++] = numVertices - 1;
                  indices[_loc166_ = indicesCount++] = 8;
               }
               ++i;
            }
         }
         this.strokePoints[_loc153_ = strokePointCount++] = 0;
         this.strokePoints[_loc154_ = strokePointCount++] = this._height - blr;
         this.strokePoints[_loc155_ = strokePointCount++] = 0;
         this.strokePoints[_loc156_ = strokePointCount++] = tlr;
      }
   }
}
