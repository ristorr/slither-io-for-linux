package starling.display.graphics
{
   import flash.geom.Point;
   import starling.display.DisplayObject;
   import starling.display.graphics.util.TriangleUtil;
   import starling.display.util.MathUtil;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   
   public class Stroke extends starling.display.graphics.GraphicRenderer
   {
      
      public static const JOINT_TYPE_MITER:int = 1;
      
      public static const JOINT_TYPE_BEVEL:int = 2;
      
      public static const JOINT_TYPE_ROUND:int = 3;
      
      protected static const DEGENERATE_START_VERTICE_TYPE:uint = 1;
      
      protected static const DEGENERATE_END_VERTICE_TYPE:uint = 2;
      
      protected static var sCollissionHelper:StrokeCollisionHelper = null;
      
      private static var lastVertex:starling.display.graphics.StrokeVertex;
      
      private static var u:Number;
      
      private static var textures:Vector.<Texture>;
      
      private static var prevVertex:starling.display.graphics.StrokeVertex;
      
      private static var dx:Number;
      
      private static var dy:Number;
      
      private static var d:Number;
      
      private static var r0:Number;
      
      private static var g0:Number;
      
      private static var b0:Number;
      
      private static var r1:Number;
      
      private static var g1:Number;
      
      private static var b1:Number;
      
      private static var v:starling.display.graphics.StrokeVertex;
      
      private static var previousVertex:starling.display.graphics.StrokeVertex;
      
      private static const MIN_ANGLE_BUFFER:Number = 5e-11;
      
      private static var vertCounter:int;
      
      private static var indiciesCounter:int;
      
      private static var isFirstVertice:Boolean;
      
      private static var isMiddleVertice:Boolean;
      
      private static var isLastVertice:Boolean;
      
      private static var numVertices:int;
      
      private static var lastVerticeIndex:int;
      
      private static var d0:Number;
      
      private static var d1:Number;
      
      private static var halfLineThickness:Number;
      
      private static var verticeAngle:Number;
      
      private static var nextVerticeAngle:Number;
      
      private static var pointAngle:Number;
      
      private static var nextPointAngle:Number;
      
      private static var angleCos:Number;
      
      private static var angleSin:Number;
      
      private static var isAngleSwitched:Boolean;
      
      private static var angleBetweenLines:Number;
      
      private static var startAngleVertice:starling.display.graphics.StrokeVertex;
      
      private static var previousVertice:starling.display.graphics.StrokeVertex;
      
      private static var currentVertice:starling.display.graphics.StrokeVertex;
      
      private static var nextVertice:starling.display.graphics.StrokeVertex;
      
      private static var dAx:Number;
      
      private static var dAy:Number;
      
      private static var dBx:Number;
      
      private static var dBy:Number;
      
      private static var cnx:Number;
      
      private static var cny:Number;
      
      private static var startX:Number;
      
      private static var startY:Number;
      
      private static var startNegativeX:Number;
      
      private static var startNegativeY:Number;
      
      private static var endX:Number;
      
      private static var endY:Number;
      
      private static var endNegativeX:Number;
      
      private static var endNegativeY:Number;
      
      private static var nextStartX:Number;
      
      private static var nextStartY:Number;
      
      private static var nextStartNegativeX:Number;
      
      private static var nextStartNegativeY:Number;
      
      private static var nextEndX:Number;
      
      private static var nextEndY:Number;
      
      private static var nextEndNegativeX:Number;
      
      private static var nextEndNegativeY:Number;
      
      private static var prevVerticeAngle:Number;
      
      private static var angleDifference:Number;
      
      private static var indiceIndex:int;
      
      private static var sharedIndice1:int;
      
      private static var sharedIndice2:int;
      
      private static var i:int;
      
      private static var c:int;
      
      private static var clen:int;
      
      private static var degenerateIndex:int = 0;
      
      private static var dot:Number;
      
      private static var arcCosDot:Number;
      
      private static var intersectionPoint:Point = new Point();
      
      private static var doesTopIntersect:Boolean;
      
      private static var doesBottomIntersect:Boolean;
      
      private static var hasIntersection:Boolean;
      
      private static var topLineIntersectResult:Point = new Point();
      
      private static var bottomLineIntersectResult:Point = new Point();
      
      private static var isClockWise:Boolean;
      
      private static var canCalculateAngleBetweenLines:Boolean;
      
      private static var isSharpAngle:Boolean;
      
      private static var absAngle:Number;
      
      private static var isPreviousVerticeJoint:Boolean;
      
      private static var intersectPointX:Number;
      
      private static var intersectPointY:Number;
      
      private static var intersectPointBottomX:Number;
      
      private static var intersectPointBottomY:Number;
      
      private static var jointBPointX:Number;
      
      private static var jointBPointY:Number;
      
      private static var jointCPointX:Number;
      
      private static var jointCPointY:Number;
      
      private static var intersectionBPointAngle:Number;
      
      private static var intersectionCPointAngle:Number;
      
      private static var intersectionAngleDifference:Number;
      
      private static var intersectionBPointAngleIncrement:Number;
      
      private static var isAngleTooSteepForLineThickness:Boolean;
      
      private static const ROUND_JOINT_MINIMUM_POINTS:int = 12;
      
      private static const ROUND_JOINT_MAXIMUM_POINTS:int = 88;
      
      private static var pointAIndiceIndex:int;
      
      private static var pointBIndiceIndex:int;
      
      private static var roundJointPointCount:int;
      
      private static var roundJointIndiceIndex:int;
      
      private static var roundJointRadius:Number;
      
      private static var roundJointRadiusCenterX:Number;
      
      private static var roundJointRadiusCenterY:Number;
      
      private static var miterIntersectionLength:Number;
      
      private static var isMiterJointBeveled:Boolean;
      
      private static var miterJointBAngle:Number;
      
      private static var miterJointCAngle:Number;
       
      
      private var _line:Vector.<starling.display.graphics.StrokeVertex>;
      
      protected var _numVertices:uint;
      
      protected var _jointType:int;
      
      public function Stroke()
      {
         super();
         this.clear();
         this._jointType = JOINT_TYPE_MITER;
      }
      
      protected static function createPolyLinePreAlloc(param1:Vector.<starling.display.graphics.StrokeVertex>, param2:Vector.<Number>, param3:Vector.<uint>, param4:int) : void
      {
         numVertices = param1.length;
         lastVerticeIndex = numVertices - 1;
         vertCounter = 0;
         indiciesCounter = 0;
         startAngleVertice = null;
         previousVertice = null;
         isFirstVertice = false;
         isLastVertice = false;
         isPreviousVerticeJoint = false;
         verticeAngle = prevVerticeAngle = 0;
         indiceIndex = 0;
         degenerateIndex = 0;
         i = 0;
         for(; i < numVertices; ++i,++degenerateIndex)
         {
            currentVertice = param1[i];
            if(currentVertice.degenerate)
            {
               if(currentVertice.degenerate == DEGENERATE_START_VERTICE_TYPE)
               {
                  previousVertice = null;
                  startAngleVertice = null;
                  prevVertex = null;
                  nextVertice = null;
                  isAngleSwitched = false;
                  verticeAngle = prevVerticeAngle = 0;
                  prevVerticeAngle = 0;
                  startX = 0;
                  startY = 0;
                  startNegativeX = 0;
                  startNegativeY = 0;
                  continue;
               }
               if(i == lastVerticeIndex)
               {
                  break;
               }
               isFirstVertice = true;
               isLastVertice = false;
               canCalculateAngleBetweenLines = false;
               degenerateIndex = 0;
            }
            else
            {
               if(previousVertice && currentVertice.x == previousVertice.x && currentVertice.y == previousVertice.y)
               {
                  continue;
               }
               isFirstVertice = degenerateIndex == 0;
               isLastVertice = i == lastVerticeIndex;
               canCalculateAngleBetweenLines = degenerateIndex > 1;
            }
            nextVertice = i + 1 < numVertices ? param1[i + 1] : null;
            if(Boolean(nextVertice) && Boolean(nextVertice.degenerate))
            {
               isLastVertice = nextVertice.degenerate == DEGENERATE_START_VERTICE_TYPE;
            }
            isMiddleVertice = !isFirstVertice && !isLastVertice;
            startAngleVertice = canCalculateAngleBetweenLines ? param1[i - 2] : null;
            if(!currentVertice.degenerate)
            {
               halfLineThickness = currentVertice.thickness * 0.5;
            }
            if(!isFirstVertice)
            {
               pointAngle = verticeAngle + MathUtil.HALF_PI;
               angleCos = Math.cos(pointAngle);
               angleSin = Math.sin(pointAngle);
               endX = currentVertice.x + halfLineThickness * angleCos;
               endY = currentVertice.y + halfLineThickness * angleSin;
               pointAngle = verticeAngle - MathUtil.HALF_PI;
               angleCos = Math.cos(pointAngle);
               angleSin = Math.sin(pointAngle);
               endNegativeX = currentVertice.x + halfLineThickness * angleCos;
               endNegativeY = currentVertice.y + halfLineThickness * angleSin;
            }
            if(!isLastVertice)
            {
               cnx = nextVertice.x - currentVertice.x;
               cny = nextVertice.y - currentVertice.y;
               verticeAngle = Math.atan2(cny,cnx);
            }
            pointAngle = verticeAngle + MathUtil.HALF_PI;
            angleCos = Math.cos(pointAngle);
            angleSin = Math.sin(pointAngle);
            nextStartX = currentVertice.x + halfLineThickness * angleCos;
            nextStartY = currentVertice.y + halfLineThickness * angleSin;
            pointAngle = verticeAngle - MathUtil.HALF_PI;
            angleCos = Math.cos(pointAngle);
            angleSin = Math.sin(pointAngle);
            nextStartNegativeX = currentVertice.x + halfLineThickness * angleCos;
            nextStartNegativeY = currentVertice.y + halfLineThickness * angleSin;
            angleDifference = prevVerticeAngle - verticeAngle;
            angleDifference = angleDifference < 0 ? -angleDifference : angleDifference;
            if(isMiddleVertice && angleDifference != 0 && angleDifference > MIN_ANGLE_BUFFER)
            {
               pointAngle = verticeAngle + MathUtil.HALF_PI;
               angleCos = Math.cos(pointAngle);
               angleSin = Math.sin(pointAngle);
               nextEndX = nextVertice.x + halfLineThickness * angleCos;
               nextEndY = nextVertice.y + halfLineThickness * angleSin;
               pointAngle = verticeAngle - MathUtil.HALF_PI;
               angleCos = Math.cos(pointAngle);
               angleSin = Math.sin(pointAngle);
               nextEndNegativeX = nextVertice.x + halfLineThickness * angleCos;
               nextEndNegativeY = nextVertice.y + halfLineThickness * angleSin;
               doesBottomIntersect = MathUtil.calculateLineIntersectionPoint(startX,startY,endX,endY,nextStartX,nextStartY,nextEndX,nextEndY,bottomLineIntersectResult);
               doesTopIntersect = MathUtil.calculateLineIntersectionPoint(startNegativeX,startNegativeY,endNegativeX,endNegativeY,nextStartNegativeX,nextStartNegativeY,nextEndNegativeX,nextEndNegativeY,topLineIntersectResult);
               hasIntersection = doesBottomIntersect || doesTopIntersect;
            }
            else
            {
               hasIntersection = false;
            }
            if(param4 && hasIntersection && isMiddleVertice)
            {
               if(param4 == JOINT_TYPE_MITER)
               {
                  isClockWise = Math.sin(prevVerticeAngle - verticeAngle) > 0;
                  if(isClockWise)
                  {
                     jointBPointX = endX;
                     jointBPointY = endY;
                     intersectPointX = topLineIntersectResult.x;
                     intersectPointY = topLineIntersectResult.y;
                     intersectPointBottomX = bottomLineIntersectResult.x;
                     intersectPointBottomY = bottomLineIntersectResult.y;
                     jointCPointX = nextStartX;
                     jointCPointY = nextStartY;
                     miterJointBAngle = prevVerticeAngle;
                     miterJointCAngle = verticeAngle + Math.PI;
                  }
                  else
                  {
                     jointBPointX = nextStartNegativeX;
                     jointBPointY = nextStartNegativeY;
                     intersectPointX = bottomLineIntersectResult.x;
                     intersectPointY = bottomLineIntersectResult.y;
                     intersectPointBottomX = topLineIntersectResult.x;
                     intersectPointBottomY = topLineIntersectResult.y;
                     jointCPointX = endNegativeX;
                     jointCPointY = endNegativeY;
                     miterJointCAngle = prevVerticeAngle;
                     miterJointBAngle = verticeAngle - Math.PI;
                  }
                  dAx = intersectPointBottomX - jointBPointX;
                  dAy = intersectPointBottomY - jointBPointY;
                  miterIntersectionLength = Math.sqrt(dAx * dAx + dAy * dAy);
                  isMiterJointBeveled = miterIntersectionLength > currentVertice.thickness;
                  if(isMiterJointBeveled)
                  {
                     var _loc5_:*;
                     param2[_loc5_ = vertCounter++] = jointBPointX + currentVertice.thickness * Math.cos(miterJointBAngle);
                     var _loc6_:*;
                     param2[_loc6_ = vertCounter++] = jointBPointY + currentVertice.thickness * Math.sin(miterJointBAngle);
                     var _loc7_:*;
                     param2[_loc7_ = vertCounter++] = 0;
                     var _loc8_:*;
                     param2[_loc8_ = vertCounter++] = currentVertice.r1;
                     var _loc9_:*;
                     param2[_loc9_ = vertCounter++] = currentVertice.g1;
                     var _loc10_:*;
                     param2[_loc10_ = vertCounter++] = currentVertice.b1;
                     var _loc11_:*;
                     param2[_loc11_ = vertCounter++] = currentVertice.a1;
                     var _loc12_:*;
                     param2[_loc12_ = vertCounter++] = currentVertice.u;
                     var _loc13_:*;
                     param2[_loc13_ = vertCounter++] = 1;
                     var _loc14_:*;
                     param2[_loc14_ = vertCounter++] = intersectPointX;
                     var _loc15_:*;
                     param2[_loc15_ = vertCounter++] = intersectPointY;
                     var _loc16_:*;
                     param2[_loc16_ = vertCounter++] = 1;
                     var _loc17_:*;
                     param2[_loc17_ = vertCounter++] = currentVertice.r1;
                     var _loc18_:*;
                     param2[_loc18_ = vertCounter++] = currentVertice.g1;
                     var _loc19_:*;
                     param2[_loc19_ = vertCounter++] = currentVertice.b1;
                     var _loc20_:*;
                     param2[_loc20_ = vertCounter++] = currentVertice.a1;
                     var _loc21_:*;
                     param2[_loc21_ = vertCounter++] = currentVertice.u;
                     var _loc22_:*;
                     param2[_loc22_ = vertCounter++] = 0;
                     var _loc23_:*;
                     param2[_loc23_ = vertCounter++] = jointCPointX + currentVertice.thickness * Math.cos(miterJointCAngle);
                     var _loc24_:*;
                     param2[_loc24_ = vertCounter++] = jointCPointY + currentVertice.thickness * Math.sin(miterJointCAngle);
                     var _loc25_:*;
                     param2[_loc25_ = vertCounter++] = 0;
                     var _loc26_:*;
                     param2[_loc26_ = vertCounter++] = currentVertice.r1;
                     var _loc27_:*;
                     param2[_loc27_ = vertCounter++] = currentVertice.g1;
                     var _loc28_:*;
                     param2[_loc28_ = vertCounter++] = currentVertice.b1;
                     var _loc29_:*;
                     param2[_loc29_ = vertCounter++] = currentVertice.a1;
                     var _loc30_:*;
                     param2[_loc30_ = vertCounter++] = currentVertice.u;
                     var _loc31_:*;
                     param2[_loc31_ = vertCounter++] = 0;
                  }
                  else
                  {
                     param2[_loc5_ = vertCounter++] = bottomLineIntersectResult.x;
                     param2[_loc6_ = vertCounter++] = bottomLineIntersectResult.y;
                     param2[_loc7_ = vertCounter++] = 0;
                     param2[_loc8_ = vertCounter++] = currentVertice.r1;
                     param2[_loc9_ = vertCounter++] = currentVertice.g1;
                     param2[_loc10_ = vertCounter++] = currentVertice.b1;
                     param2[_loc11_ = vertCounter++] = currentVertice.a1;
                     param2[_loc12_ = vertCounter++] = currentVertice.u;
                     param2[_loc13_ = vertCounter++] = 1;
                     param2[_loc14_ = vertCounter++] = topLineIntersectResult.x;
                     param2[_loc15_ = vertCounter++] = topLineIntersectResult.y;
                     param2[_loc16_ = vertCounter++] = 0;
                     param2[_loc17_ = vertCounter++] = currentVertice.r1;
                     param2[_loc18_ = vertCounter++] = currentVertice.g1;
                     param2[_loc19_ = vertCounter++] = currentVertice.b1;
                     param2[_loc20_ = vertCounter++] = currentVertice.a1;
                     param2[_loc21_ = vertCounter++] = currentVertice.u;
                     param2[_loc22_ = vertCounter++] = 0;
                  }
               }
               else if(param4 == JOINT_TYPE_BEVEL || param4 == JOINT_TYPE_ROUND)
               {
                  isClockWise = Math.sin(prevVerticeAngle - verticeAngle) > 0;
                  if(isClockWise)
                  {
                     jointBPointX = endX;
                     jointBPointY = endY;
                     intersectPointX = topLineIntersectResult.x;
                     intersectPointY = topLineIntersectResult.y;
                     jointCPointX = nextStartX;
                     jointCPointY = nextStartY;
                  }
                  else
                  {
                     jointBPointX = nextStartNegativeX;
                     jointBPointY = nextStartNegativeY;
                     intersectPointX = bottomLineIntersectResult.x;
                     intersectPointY = bottomLineIntersectResult.y;
                     jointCPointX = endNegativeX;
                     jointCPointY = endNegativeY;
                  }
                  param2[_loc5_ = vertCounter++] = jointBPointX;
                  param2[_loc6_ = vertCounter++] = jointBPointY;
                  param2[_loc7_ = vertCounter++] = 0;
                  param2[_loc8_ = vertCounter++] = currentVertice.r1;
                  param2[_loc9_ = vertCounter++] = currentVertice.g1;
                  param2[_loc10_ = vertCounter++] = currentVertice.b1;
                  param2[_loc11_ = vertCounter++] = currentVertice.a1;
                  param2[_loc12_ = vertCounter++] = currentVertice.u;
                  param2[_loc13_ = vertCounter++] = 1;
                  param2[_loc14_ = vertCounter++] = intersectPointX;
                  param2[_loc15_ = vertCounter++] = intersectPointY;
                  param2[_loc16_ = vertCounter++] = 0;
                  param2[_loc17_ = vertCounter++] = currentVertice.r1;
                  param2[_loc18_ = vertCounter++] = currentVertice.g1;
                  param2[_loc19_ = vertCounter++] = currentVertice.b1;
                  param2[_loc20_ = vertCounter++] = currentVertice.a1;
                  param2[_loc21_ = vertCounter++] = currentVertice.u;
                  param2[_loc22_ = vertCounter++] = 0;
                  if(param4 == JOINT_TYPE_ROUND)
                  {
                     if(isClockWise)
                     {
                        dAx = jointBPointX - currentVertice.x;
                        dAy = jointBPointY - currentVertice.y;
                        intersectionBPointAngle = Math.atan2(dAy,dAx);
                        dAx = jointCPointX - currentVertice.x;
                        dAy = jointCPointY - currentVertice.y;
                        intersectionCPointAngle = Math.atan2(dAy,dAx);
                     }
                     else
                     {
                        dAx = jointCPointX - currentVertice.x;
                        dAy = jointCPointY - currentVertice.y;
                        intersectionBPointAngle = Math.atan2(dAy,dAx);
                        dAx = jointBPointX - currentVertice.x;
                        dAy = jointBPointY - currentVertice.y;
                        intersectionCPointAngle = Math.atan2(dAy,dAx);
                     }
                     roundJointRadius = currentVertice.thickness * 0.5;
                     roundJointPointCount = Math.round(roundJointRadius);
                     if(roundJointPointCount > ROUND_JOINT_MAXIMUM_POINTS)
                     {
                        roundJointPointCount = ROUND_JOINT_MAXIMUM_POINTS;
                     }
                     else if(roundJointPointCount < ROUND_JOINT_MINIMUM_POINTS)
                     {
                        roundJointPointCount = ROUND_JOINT_MINIMUM_POINTS;
                     }
                     intersectionAngleDifference = Math.abs(intersectionBPointAngle - intersectionCPointAngle) % MathUtil.FULL_CIRCLE_ANGLE;
                     intersectionAngleDifference = intersectionAngleDifference > Math.PI ? MathUtil.FULL_CIRCLE_ANGLE - intersectionAngleDifference : intersectionAngleDifference;
                     intersectionBPointAngleIncrement = Math.abs(intersectionAngleDifference / roundJointPointCount);
                     intersectionBPointAngleIncrement = intersectionBPointAngleIncrement < 0 ? -intersectionBPointAngleIncrement : intersectionBPointAngleIncrement;
                     if(isClockWise)
                     {
                        --roundJointPointCount;
                     }
                     if(isClockWise)
                     {
                        intersectionBPointAngleIncrement *= -1;
                     }
                     intersectionBPointAngle += intersectionBPointAngleIncrement;
                     roundJointRadiusCenterX = (jointBPointX + jointCPointX) * 0.5;
                     roundJointRadiusCenterY = (jointBPointY + jointCPointY) * 0.5;
                     c = 0;
                     while(c < roundJointPointCount)
                     {
                        dBx = currentVertice.x + roundJointRadius * Math.cos(intersectionBPointAngle);
                        dBy = currentVertice.y + roundJointRadius * Math.sin(intersectionBPointAngle);
                        param2[_loc23_ = vertCounter++] = dBx;
                        param2[_loc24_ = vertCounter++] = dBy;
                        param2[_loc25_ = vertCounter++] = 0;
                        param2[_loc26_ = vertCounter++] = currentVertice.r1;
                        param2[_loc27_ = vertCounter++] = currentVertice.g1;
                        param2[_loc28_ = vertCounter++] = currentVertice.b1;
                        param2[_loc29_ = vertCounter++] = currentVertice.a1;
                        param2[_loc30_ = vertCounter++] = currentVertice.u;
                        param2[_loc31_ = vertCounter++] = Math.cos(intersectionBPointAngle);
                        ++c;
                        intersectionBPointAngle += intersectionBPointAngleIncrement;
                     }
                  }
                  param2[_loc23_ = vertCounter++] = jointCPointX;
                  param2[_loc24_ = vertCounter++] = jointCPointY;
                  param2[_loc25_ = vertCounter++] = 0;
                  param2[_loc26_ = vertCounter++] = currentVertice.r1;
                  param2[_loc27_ = vertCounter++] = currentVertice.g1;
                  param2[_loc28_ = vertCounter++] = currentVertice.b1;
                  param2[_loc29_ = vertCounter++] = currentVertice.a1;
                  param2[_loc30_ = vertCounter++] = currentVertice.u;
                  param2[_loc31_ = vertCounter++] = 0;
               }
            }
            else
            {
               isSharpAngle = false;
               if(canCalculateAngleBetweenLines)
               {
                  dAx = startAngleVertice.x - previousVertice.x;
                  dAy = startAngleVertice.y - previousVertice.y;
                  dBx = currentVertice.x - previousVertice.x;
                  dBy = currentVertice.y - previousVertice.y;
                  angleBetweenLines = Math.atan2(dAx * dBy - dAy * dBx,dAx * dBx + dAy * dBy);
                  absAngle = angleBetweenLines < 0 ? -angleBetweenLines : angleBetweenLines;
                  isSharpAngle = absAngle < MathUtil.HALF_PI;
               }
               if(!param4)
               {
                  if(isFirstVertice)
                  {
                     param2[_loc5_ = vertCounter++] = nextStartX;
                     param2[_loc6_ = vertCounter++] = nextStartY;
                     param2[_loc7_ = vertCounter++] = 0;
                     param2[_loc8_ = vertCounter++] = currentVertice.r2;
                     param2[_loc9_ = vertCounter++] = currentVertice.g2;
                     param2[_loc10_ = vertCounter++] = currentVertice.b2;
                     param2[_loc11_ = vertCounter++] = currentVertice.a2;
                     param2[_loc12_ = vertCounter++] = currentVertice.u;
                     param2[_loc13_ = vertCounter++] = 1;
                     param2[_loc14_ = vertCounter++] = nextStartNegativeX;
                     param2[_loc15_ = vertCounter++] = nextStartNegativeY;
                     param2[_loc16_ = vertCounter++] = 0;
                     param2[_loc17_ = vertCounter++] = currentVertice.r1;
                     param2[_loc18_ = vertCounter++] = currentVertice.g1;
                     param2[_loc19_ = vertCounter++] = currentVertice.b1;
                     param2[_loc20_ = vertCounter++] = currentVertice.a1;
                     param2[_loc21_ = vertCounter++] = currentVertice.u;
                     param2[_loc22_ = vertCounter++] = 0;
                  }
                  else if(canCalculateAngleBetweenLines && (isSharpAngle && !isAngleSwitched || !isSharpAngle && isAngleSwitched))
                  {
                     isAngleSwitched = true;
                     param2[_loc5_ = vertCounter++] = endNegativeX;
                     param2[_loc6_ = vertCounter++] = endNegativeY;
                     param2[_loc7_ = vertCounter++] = 0;
                     param2[_loc8_ = vertCounter++] = currentVertice.r2;
                     param2[_loc9_ = vertCounter++] = currentVertice.g2;
                     param2[_loc10_ = vertCounter++] = currentVertice.b2;
                     param2[_loc11_ = vertCounter++] = currentVertice.a2;
                     param2[_loc12_ = vertCounter++] = currentVertice.u;
                     param2[_loc13_ = vertCounter++] = 1;
                     param2[_loc14_ = vertCounter++] = endX;
                     param2[_loc15_ = vertCounter++] = endY;
                     param2[_loc16_ = vertCounter++] = 0;
                     param2[_loc17_ = vertCounter++] = currentVertice.r1;
                     param2[_loc18_ = vertCounter++] = currentVertice.g1;
                     param2[_loc19_ = vertCounter++] = currentVertice.b1;
                     param2[_loc20_ = vertCounter++] = currentVertice.a1;
                     param2[_loc21_ = vertCounter++] = currentVertice.u;
                     param2[_loc22_ = vertCounter++] = 0;
                  }
                  else
                  {
                     param2[_loc5_ = vertCounter++] = endX;
                     param2[_loc6_ = vertCounter++] = endY;
                     param2[_loc7_ = vertCounter++] = 0;
                     param2[_loc8_ = vertCounter++] = currentVertice.r2;
                     param2[_loc9_ = vertCounter++] = currentVertice.g2;
                     param2[_loc10_ = vertCounter++] = currentVertice.b2;
                     param2[_loc11_ = vertCounter++] = currentVertice.a2;
                     param2[_loc12_ = vertCounter++] = currentVertice.u;
                     param2[_loc13_ = vertCounter++] = 1;
                     param2[_loc14_ = vertCounter++] = endNegativeX;
                     param2[_loc15_ = vertCounter++] = endNegativeY;
                     param2[_loc16_ = vertCounter++] = 0;
                     param2[_loc17_ = vertCounter++] = currentVertice.r1;
                     param2[_loc18_ = vertCounter++] = currentVertice.g1;
                     param2[_loc19_ = vertCounter++] = currentVertice.b1;
                     param2[_loc20_ = vertCounter++] = currentVertice.a1;
                     param2[_loc21_ = vertCounter++] = currentVertice.u;
                     param2[_loc22_ = vertCounter++] = 0;
                     isAngleSwitched = false;
                  }
               }
               else if(!isPreviousVerticeJoint && canCalculateAngleBetweenLines && (isSharpAngle && !isAngleSwitched || !isSharpAngle && isAngleSwitched))
               {
                  isAngleSwitched = true;
                  param2[_loc5_ = vertCounter++] = nextStartNegativeX;
                  param2[_loc6_ = vertCounter++] = nextStartNegativeY;
                  param2[_loc7_ = vertCounter++] = 0;
                  param2[_loc8_ = vertCounter++] = currentVertice.r2;
                  param2[_loc9_ = vertCounter++] = currentVertice.g2;
                  param2[_loc10_ = vertCounter++] = currentVertice.b2;
                  param2[_loc11_ = vertCounter++] = currentVertice.a2;
                  param2[_loc12_ = vertCounter++] = currentVertice.u;
                  param2[_loc13_ = vertCounter++] = 1;
                  param2[_loc14_ = vertCounter++] = nextStartX;
                  param2[_loc15_ = vertCounter++] = nextStartY;
                  param2[_loc16_ = vertCounter++] = 0;
                  param2[_loc17_ = vertCounter++] = currentVertice.r1;
                  param2[_loc18_ = vertCounter++] = currentVertice.g1;
                  param2[_loc19_ = vertCounter++] = currentVertice.b1;
                  param2[_loc20_ = vertCounter++] = currentVertice.a1;
                  param2[_loc21_ = vertCounter++] = currentVertice.u;
                  param2[_loc22_ = vertCounter++] = 0;
               }
               else
               {
                  isAngleSwitched = false;
                  param2[_loc5_ = vertCounter++] = nextStartX;
                  param2[_loc6_ = vertCounter++] = nextStartY;
                  param2[_loc7_ = vertCounter++] = 0;
                  param2[_loc8_ = vertCounter++] = currentVertice.r2;
                  param2[_loc9_ = vertCounter++] = currentVertice.g2;
                  param2[_loc10_ = vertCounter++] = currentVertice.b2;
                  param2[_loc11_ = vertCounter++] = currentVertice.a2;
                  param2[_loc12_ = vertCounter++] = currentVertice.u;
                  param2[_loc13_ = vertCounter++] = 1;
                  param2[_loc14_ = vertCounter++] = nextStartNegativeX;
                  param2[_loc15_ = vertCounter++] = nextStartNegativeY;
                  param2[_loc16_ = vertCounter++] = 0;
                  param2[_loc17_ = vertCounter++] = currentVertice.r1;
                  param2[_loc18_ = vertCounter++] = currentVertice.g1;
                  param2[_loc19_ = vertCounter++] = currentVertice.b1;
                  param2[_loc20_ = vertCounter++] = currentVertice.a1;
                  param2[_loc21_ = vertCounter++] = currentVertice.u;
                  param2[_loc22_ = vertCounter++] = 0;
               }
            }
            if(isFirstVertice)
            {
               if(i == 0)
               {
                  sharedIndice1 = 0;
                  sharedIndice2 = 1;
                  indiceIndex += 2;
               }
               else
               {
                  sharedIndice1 += 2;
                  sharedIndice2 += 2;
                  indiceIndex += 2;
               }
            }
            else if(Boolean(param4) && hasIntersection)
            {
               if(param4 == JOINT_TYPE_MITER)
               {
                  if(isMiterJointBeveled)
                  {
                     if(isClockWise)
                     {
                        param3[_loc5_ = indiciesCounter++] = sharedIndice1;
                        param3[_loc6_ = indiciesCounter++] = indiceIndex;
                        param3[_loc7_ = indiciesCounter++] = sharedIndice2;
                        param3[_loc8_ = indiciesCounter++] = sharedIndice2;
                        param3[_loc9_ = indiciesCounter++] = indiceIndex;
                        param3[_loc10_ = indiciesCounter++] = indiceIndex + 1;
                        param3[_loc11_ = indiciesCounter++] = indiceIndex;
                        param3[_loc12_ = indiciesCounter++] = indiceIndex + 1;
                        param3[_loc13_ = indiciesCounter++] = indiceIndex + 2;
                        sharedIndice1 = indiceIndex + 2;
                        sharedIndice2 = indiceIndex + 1;
                     }
                     else
                     {
                        param3[_loc5_ = indiciesCounter++] = sharedIndice1;
                        param3[_loc6_ = indiciesCounter++] = indiceIndex + 1;
                        param3[_loc7_ = indiciesCounter++] = sharedIndice2;
                        param3[_loc8_ = indiciesCounter++] = indiceIndex + 1;
                        param3[_loc9_ = indiciesCounter++] = sharedIndice2;
                        param3[_loc10_ = indiciesCounter++] = indiceIndex + 2;
                        param3[_loc11_ = indiciesCounter++] = indiceIndex + 1;
                        param3[_loc12_ = indiciesCounter++] = indiceIndex;
                        param3[_loc13_ = indiciesCounter++] = indiceIndex + 2;
                        sharedIndice1 = indiceIndex + 1;
                        sharedIndice2 = indiceIndex;
                     }
                     indiceIndex += 3;
                  }
                  else
                  {
                     param3[_loc5_ = indiciesCounter++] = sharedIndice1;
                     param3[_loc6_ = indiciesCounter++] = indiceIndex;
                     param3[_loc7_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc8_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc9_ = indiciesCounter++] = indiceIndex;
                     param3[_loc10_ = indiciesCounter++] = indiceIndex + 1;
                     sharedIndice1 = indiceIndex;
                     sharedIndice2 = indiceIndex + 1;
                     indiceIndex += 2;
                  }
               }
               else if(param4 == JOINT_TYPE_BEVEL)
               {
                  if(isClockWise)
                  {
                     param3[_loc5_ = indiciesCounter++] = sharedIndice1;
                     param3[_loc6_ = indiciesCounter++] = indiceIndex;
                     param3[_loc7_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc8_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc9_ = indiciesCounter++] = indiceIndex;
                     param3[_loc10_ = indiciesCounter++] = indiceIndex + 1;
                     param3[_loc11_ = indiciesCounter++] = indiceIndex;
                     param3[_loc12_ = indiciesCounter++] = indiceIndex + 1;
                     param3[_loc13_ = indiciesCounter++] = indiceIndex + 2;
                     sharedIndice1 = indiceIndex + 2;
                     sharedIndice2 = indiceIndex + 1;
                  }
                  else
                  {
                     param3[_loc5_ = indiciesCounter++] = sharedIndice1;
                     param3[_loc6_ = indiciesCounter++] = indiceIndex + 1;
                     param3[_loc7_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc8_ = indiciesCounter++] = indiceIndex + 1;
                     param3[_loc9_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc10_ = indiciesCounter++] = indiceIndex + 2;
                     param3[_loc11_ = indiciesCounter++] = indiceIndex + 1;
                     param3[_loc12_ = indiciesCounter++] = indiceIndex;
                     param3[_loc13_ = indiciesCounter++] = indiceIndex + 2;
                     sharedIndice1 = indiceIndex + 1;
                     sharedIndice2 = indiceIndex;
                  }
                  indiceIndex += 3;
               }
               else
               {
                  if(isClockWise)
                  {
                     param3[_loc5_ = indiciesCounter++] = sharedIndice1;
                     param3[_loc6_ = indiciesCounter++] = indiceIndex;
                     param3[_loc7_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc8_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc9_ = indiciesCounter++] = indiceIndex;
                     param3[_loc10_ = indiciesCounter++] = indiceIndex + 1;
                     pointBIndiceIndex = indiceIndex;
                     pointAIndiceIndex = indiceIndex + 1;
                     roundJointIndiceIndex = pointAIndiceIndex;
                     c = 0;
                     while(c < roundJointPointCount)
                     {
                        if(c == 0)
                        {
                           param3[_loc11_ = indiciesCounter++] = pointAIndiceIndex;
                           param3[_loc12_ = indiciesCounter++] = pointBIndiceIndex;
                           param3[_loc13_ = indiciesCounter++] = ++roundJointIndiceIndex;
                        }
                        else
                        {
                           param3[_loc11_ = indiciesCounter++] = pointAIndiceIndex;
                           param3[_loc12_ = indiciesCounter++] = roundJointIndiceIndex;
                           param3[_loc13_ = indiciesCounter++] = ++roundJointIndiceIndex;
                        }
                        ++indiceIndex;
                        ++c;
                     }
                     sharedIndice1 = roundJointIndiceIndex;
                     sharedIndice2 = pointAIndiceIndex;
                  }
                  else
                  {
                     param3[_loc5_ = indiciesCounter++] = sharedIndice1;
                     param3[_loc6_ = indiciesCounter++] = indiceIndex + 1;
                     param3[_loc7_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc8_ = indiciesCounter++] = indiceIndex + 1;
                     param3[_loc9_ = indiciesCounter++] = sharedIndice2;
                     param3[_loc10_ = indiciesCounter++] = indiceIndex + 2;
                     pointBIndiceIndex = indiceIndex;
                     pointAIndiceIndex = indiceIndex + 1;
                     roundJointIndiceIndex = pointAIndiceIndex;
                     c = 0;
                     while(c < roundJointPointCount)
                     {
                        param3[_loc11_ = indiciesCounter++] = pointAIndiceIndex;
                        param3[_loc12_ = indiciesCounter++] = roundJointIndiceIndex;
                        param3[_loc13_ = indiciesCounter++] = ++roundJointIndiceIndex;
                        ++indiceIndex;
                        ++c;
                     }
                     sharedIndice1 = pointAIndiceIndex;
                     sharedIndice2 = roundJointIndiceIndex;
                  }
                  indiceIndex += 3;
               }
            }
            else
            {
               param3[_loc5_ = indiciesCounter++] = sharedIndice1;
               param3[_loc6_ = indiciesCounter++] = indiceIndex;
               param3[_loc7_ = indiciesCounter++] = sharedIndice2;
               param3[_loc8_ = indiciesCounter++] = sharedIndice2;
               param3[_loc9_ = indiciesCounter++] = indiceIndex;
               param3[_loc10_ = indiciesCounter++] = indiceIndex + 1;
               sharedIndice1 = indiceIndex;
               sharedIndice2 = indiceIndex + 1;
               indiceIndex += 2;
            }
            previousVertice = currentVertice;
            prevVerticeAngle = verticeAngle;
            startX = nextStartX;
            startY = nextStartY;
            startNegativeX = nextStartNegativeX;
            startNegativeY = nextStartNegativeY;
            isPreviousVerticeJoint = hasIntersection && Boolean(param4);
         }
      }
      
      protected static function createPolyLine(param1:Vector.<starling.display.graphics.StrokeVertex>, param2:Vector.<Number>, param3:Vector.<uint>, param4:int) : void
      {
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         var _loc16_:starling.display.graphics.StrokeVertex = null;
         var _loc17_:starling.display.graphics.StrokeVertex = null;
         var _loc18_:starling.display.graphics.StrokeVertex = null;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc42_:Number = NaN;
         var _loc43_:Number = NaN;
         var _loc44_:int = 0;
         var _loc5_:Function = Math.sqrt;
         var _loc6_:Function = Math.sin;
         var _loc7_:int = int(param1.length);
         var _loc8_:Number = Math.PI;
         var _loc9_:int = 0;
         while(_loc9_ < _loc7_)
         {
            _loc10_ = param1[_loc9_].degenerate;
            _loc11_ = uint(_loc9_);
            if(_loc10_ != 0)
            {
               _loc11_ = _loc10_ == DEGENERATE_END_VERTICE_TYPE ? uint(_loc9_ - 1) : uint(_loc9_ + 1);
            }
            _loc12_ = _loc11_ == 0 || param1[_loc11_ - 1].degenerate > 0;
            _loc13_ = _loc11_ == _loc7_ - 1 || param1[_loc11_ + 1].degenerate > 0;
            _loc14_ = _loc12_ ? _loc11_ : _loc11_ - 1;
            _loc15_ = _loc13_ ? _loc11_ : uint(_loc11_ + 1);
            _loc16_ = param1[_loc14_];
            _loc17_ = param1[_loc11_];
            _loc18_ = param1[_loc15_];
            _loc19_ = _loc16_.x;
            _loc20_ = _loc16_.y;
            _loc21_ = _loc17_.x;
            _loc22_ = _loc17_.y;
            _loc23_ = _loc18_.x;
            _loc24_ = _loc18_.y;
            _loc25_ = _loc21_ - _loc19_;
            _loc26_ = _loc22_ - _loc20_;
            _loc27_ = _loc23_ - _loc21_;
            _loc28_ = _loc24_ - _loc22_;
            if(_loc13_)
            {
               _loc23_ += _loc25_;
               _loc24_ += _loc26_;
               _loc27_ = _loc23_ - _loc21_;
               _loc28_ = _loc24_ - _loc22_;
            }
            if(_loc12_)
            {
               _loc19_ -= _loc27_;
               _loc20_ -= _loc28_;
               _loc25_ = _loc21_ - _loc19_;
               _loc26_ = _loc22_ - _loc20_;
            }
            _loc29_ = _loc5_(_loc25_ * _loc25_ + _loc26_ * _loc26_);
            _loc30_ = _loc5_(_loc27_ * _loc27_ + _loc28_ * _loc28_);
            _loc31_ = _loc17_.thickness * 0.5;
            if(!(_loc12_ || _loc13_))
            {
               _loc43_ = (_loc25_ * _loc27_ + _loc26_ * _loc28_) / (_loc29_ * _loc30_);
               if((_loc31_ /= _loc6_((_loc8_ - Math.acos(_loc43_)) * 0.5)) > _loc17_.thickness * 4)
               {
                  _loc31_ = _loc17_.thickness * 4;
               }
               if(isNaN(_loc31_))
               {
                  _loc31_ = _loc17_.thickness * 0.5;
               }
            }
            _loc32_ = -_loc26_ / _loc29_;
            _loc33_ = _loc25_ / _loc29_;
            _loc34_ = -_loc28_ / _loc30_;
            _loc35_ = _loc27_ / _loc30_;
            _loc36_ = _loc32_ + _loc34_;
            _loc37_ = _loc33_ + _loc35_;
            _loc38_ = 1 / _loc5_(_loc36_ * _loc36_ + _loc37_ * _loc37_) * _loc31_;
            _loc36_ *= _loc38_;
            _loc37_ *= _loc38_;
            _loc39_ = _loc21_ + _loc36_;
            _loc40_ = _loc22_ + _loc37_;
            _loc41_ = !!_loc10_ ? _loc39_ : _loc21_ - _loc36_;
            _loc42_ = !!_loc10_ ? _loc40_ : _loc22_ - _loc37_;
            param2.push(_loc39_,_loc40_,0,_loc17_.r2,_loc17_.g2,_loc17_.b2,_loc17_.a2,_loc17_.u,1,_loc41_,_loc42_,0,_loc17_.r1,_loc17_.g1,_loc17_.b1,_loc17_.a1,_loc17_.u,0);
            if(_loc9_ < _loc7_ - 1)
            {
               _loc44_ = param4 + (_loc9_ << 1);
               param3.push(_loc44_,_loc44_ + 2,_loc44_ + 1,_loc44_ + 1,_loc44_ + 2,_loc44_ + 3);
            }
            _loc9_++;
         }
      }
      
      public static function strokeCollideTest(param1:starling.display.graphics.Stroke, param2:starling.display.graphics.Stroke, param3:Point, param4:Vector.<Point> = null) : Boolean
      {
         var _loc12_:starling.display.graphics.StrokeVertex = null;
         var _loc13_:starling.display.graphics.StrokeVertex = null;
         var _loc14_:int = 0;
         var _loc15_:starling.display.graphics.StrokeVertex = null;
         var _loc16_:starling.display.graphics.StrokeVertex = null;
         if(param1 == null || param2 == null || param1._line == null || param1._line == null)
         {
            return false;
         }
         if(sCollissionHelper == null)
         {
            sCollissionHelper = new StrokeCollisionHelper();
         }
         sCollissionHelper.testIntersectPoint.x = 0;
         sCollissionHelper.testIntersectPoint.y = 0;
         param3.x = 0;
         param3.y = 0;
         var _loc5_:Boolean = false;
         if(param1.parent == param2.parent)
         {
            _loc5_ = true;
         }
         param1.getBounds(_loc5_ ? param1.parent : param1.stage,sCollissionHelper.bounds1);
         param2.getBounds(_loc5_ ? param2.parent : param2.stage,sCollissionHelper.bounds2);
         if(sCollissionHelper.bounds1.intersects(sCollissionHelper.bounds2) == false)
         {
            return false;
         }
         if(param3 == null)
         {
            param3 = new Point();
         }
         var _loc6_:int = int(param1._line.length);
         var _loc7_:int = int(param2._line.length);
         var _loc8_:Boolean = false;
         if(sCollissionHelper.s2v0Vector == null || sCollissionHelper.s2v0Vector.length < _loc7_)
         {
            sCollissionHelper.s2v0Vector = new Vector.<Point>(_loc7_,true);
            sCollissionHelper.s2v1Vector = new Vector.<Point>(_loc7_,true);
         }
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(param4 != null)
         {
            _loc10_ = int(param4.length);
         }
         var _loc11_:int = 1;
         while(_loc11_ < _loc6_)
         {
            _loc12_ = param1._line[_loc11_ - 1];
            _loc13_ = param1._line[_loc11_];
            sCollissionHelper.localPT1.setTo(_loc12_.x,_loc12_.y);
            sCollissionHelper.localPT2.setTo(_loc13_.x,_loc13_.y);
            if(_loc5_)
            {
               param1.localToParent(sCollissionHelper.localPT1,sCollissionHelper.globalPT1);
               param1.localToParent(sCollissionHelper.localPT2,sCollissionHelper.globalPT2);
            }
            else
            {
               param1.localToGlobal(sCollissionHelper.localPT1,sCollissionHelper.globalPT1);
               param1.localToGlobal(sCollissionHelper.localPT2,sCollissionHelper.globalPT2);
            }
            _loc14_ = 1;
            while(_loc14_ < _loc7_)
            {
               _loc15_ = param2._line[_loc14_ - 1];
               _loc16_ = param2._line[_loc14_];
               if(_loc11_ == 1)
               {
                  sCollissionHelper.localPT3.setTo(_loc15_.x,_loc15_.y);
                  sCollissionHelper.localPT4.setTo(_loc16_.x,_loc16_.y);
                  if(_loc5_)
                  {
                     param2.localToParent(sCollissionHelper.localPT3,sCollissionHelper.globalPT3);
                     param2.localToParent(sCollissionHelper.localPT4,sCollissionHelper.globalPT4);
                  }
                  else
                  {
                     param2.localToGlobal(sCollissionHelper.localPT3,sCollissionHelper.globalPT3);
                     param2.localToGlobal(sCollissionHelper.localPT4,sCollissionHelper.globalPT4);
                  }
                  if(sCollissionHelper.s2v0Vector[_loc14_] == null)
                  {
                     sCollissionHelper.s2v0Vector[_loc14_] = new Point(sCollissionHelper.globalPT3.x,sCollissionHelper.globalPT3.y);
                     sCollissionHelper.s2v1Vector[_loc14_] = new Point(sCollissionHelper.globalPT4.x,sCollissionHelper.globalPT4.y);
                  }
                  else
                  {
                     sCollissionHelper.s2v0Vector[_loc14_].x = sCollissionHelper.globalPT3.x;
                     sCollissionHelper.s2v0Vector[_loc14_].y = sCollissionHelper.globalPT3.y;
                     sCollissionHelper.s2v1Vector[_loc14_].x = sCollissionHelper.globalPT4.x;
                     sCollissionHelper.s2v1Vector[_loc14_].y = sCollissionHelper.globalPT4.y;
                  }
               }
               else
               {
                  sCollissionHelper.globalPT3.x = sCollissionHelper.s2v0Vector[_loc14_].x;
                  sCollissionHelper.globalPT3.y = sCollissionHelper.s2v0Vector[_loc14_].y;
                  sCollissionHelper.globalPT4.x = sCollissionHelper.s2v1Vector[_loc14_].x;
                  sCollissionHelper.globalPT4.y = sCollissionHelper.s2v1Vector[_loc14_].y;
               }
               if(TriangleUtil.lineIntersectLine(sCollissionHelper.globalPT1.x,sCollissionHelper.globalPT1.y,sCollissionHelper.globalPT2.x,sCollissionHelper.globalPT2.y,sCollissionHelper.globalPT3.x,sCollissionHelper.globalPT3.y,sCollissionHelper.globalPT4.x,sCollissionHelper.globalPT4.y,sCollissionHelper.testIntersectPoint))
               {
                  if(param4 != null && _loc9_ < _loc10_ - 1)
                  {
                     if(_loc5_)
                     {
                        param1.parent.localToGlobal(sCollissionHelper.testIntersectPoint,param4[_loc9_]);
                     }
                     else
                     {
                        param4[_loc9_].x = sCollissionHelper.testIntersectPoint.x;
                        param4[_loc9_].y = sCollissionHelper.testIntersectPoint.y;
                     }
                     _loc9_++;
                     param4[_loc9_].x = NaN;
                     param4[_loc9_].y = NaN;
                  }
                  if(sCollissionHelper.testIntersectPoint.length > param3.length)
                  {
                     if(_loc5_)
                     {
                        param1.parent.localToGlobal(sCollissionHelper.testIntersectPoint,param3);
                     }
                     else
                     {
                        param3.x = sCollissionHelper.testIntersectPoint.x;
                        param3.y = sCollissionHelper.testIntersectPoint.y;
                     }
                  }
                  _loc8_ = true;
               }
               _loc14_++;
            }
            _loc11_++;
         }
         return _loc8_;
      }
      
      public function set jointType(param1:int) : void
      {
         this._jointType = param1;
      }
      
      public function get jointType() : int
      {
         return this._jointType;
      }
      
      public function get numVertices() : uint
      {
         return this._numVertices;
      }
      
      override public function dispose() : void
      {
         this.clear();
         super.dispose();
      }
      
      public function clear() : void
      {
         if(minBounds)
         {
            minBounds.x = minBounds.y = Number.POSITIVE_INFINITY;
            maxBounds.x = maxBounds.y = Number.NEGATIVE_INFINITY;
         }
         if(this._line)
         {
            starling.display.graphics.StrokeVertex.putInstances(this._line);
            this._line.length = 0;
         }
         else
         {
            this._line = new Vector.<starling.display.graphics.StrokeVertex>();
         }
         this._numVertices = 0;
         setGeometryInvalid();
      }
      
      public function addDegenerates(param1:Number, param2:Number) : void
      {
         if(this._numVertices < 2)
         {
            lastVertex = this._line[0];
            lastVertex.x = param1;
            lastVertex.y = param2;
            return;
         }
         lastVertex = this._line[this._numVertices - 1];
         if(lastVertex.degenerate)
         {
            lastVertex.x = param1;
            lastVertex.y = param2;
            return;
         }
         if(lastVertex.x == param1 && lastVertex.y == param2)
         {
            return;
         }
         this.addVertexInternal(lastVertex.x,lastVertex.y,0);
         lastVertex = this._line[this._numVertices - 1];
         lastVertex.degenerate = DEGENERATE_START_VERTICE_TYPE;
         lastVertex.u = 1;
         this.addVertexInternal(param1,param2,0);
         lastVertex = this._line[this._numVertices - 1];
         lastVertex.degenerate = DEGENERATE_END_VERTICE_TYPE;
         lastVertex.u = 1;
      }
      
      protected function setLastVertexAsDegenerate(param1:uint) : void
      {
         this._line[this._numVertices - 1].degenerate = param1;
         this._line[this._numVertices - 1].u = 0;
      }
      
      public function lineTo(param1:Number, param2:Number, param3:Number = 1, param4:uint = 16777215, param5:Number = 1) : void
      {
         this.addVertexInternal(param1,param2,param3,param4,param5,param4,param5);
      }
      
      public function moveTo(param1:Number, param2:Number, param3:Number = 1, param4:uint = 16777215, param5:Number = 1) : void
      {
         this.addDegenerates(param1,param2);
      }
      
      public function modifyVertexPosition(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:starling.display.graphics.StrokeVertex;
         (_loc4_ = this._line[param1]).x = param2;
         _loc4_.y = param3;
         isInvalid = true;
         hasValidatedGeometry = false;
      }
      
      public function addVertex(param1:Number, param2:Number, param3:Number = 1, param4:uint = 16777215, param5:Number = 1, param6:uint = 16777215, param7:Number = 1) : void
      {
         this.addVertexInternal(param1,param2,param3,param4,param5,param6,param7);
      }
      
      protected function addVertexInternal(param1:Number, param2:Number, param3:Number = 1, param4:uint = 16777215, param5:Number = 1, param6:uint = 16777215, param7:Number = 1) : void
      {
         if(param3 > 0 && this._numVertices > 0)
         {
            previousVertex = this._line[this._numVertices - 1];
            if(previousVertex.x == param1 && previousVertex.y == param2)
            {
               return;
            }
         }
         u = 0;
         if(Boolean(_material.texture) && this._line.length > 0)
         {
            prevVertex = this._line[this._line.length - 1];
            dx = param1 - prevVertex.x;
            dy = param2 - prevVertex.y;
            d = Math.sqrt(dx * dx + dy * dy);
            u = prevVertex.u + d / _material.texture.width;
         }
         r0 = (param4 >> 16) / 255;
         g0 = ((param4 & 65280) >> 8) / 255;
         b0 = (param4 & 255) / 255;
         r1 = (param6 >> 16) / 255;
         g1 = ((param6 & 65280) >> 8) / 255;
         b1 = (param6 & 255) / 255;
         v = starling.display.graphics.StrokeVertex.getInstance();
         this._line[this._numVertices] = v;
         v.x = param1;
         v.y = param2;
         v.r1 = r0;
         v.g1 = g0;
         v.b1 = b0;
         v.a1 = param5;
         v.r2 = r1;
         v.g2 = g1;
         v.b2 = b1;
         v.a2 = param7;
         v.u = u;
         v.v = 0;
         v.thickness = param3;
         v.degenerate = 0;
         ++this._numVertices;
         if(param1 == 0)
         {
            if(minBounds.x == Number.POSITIVE_INFINITY || minBounds.x == 0)
            {
               minBounds.x = -(param3 * 0.5);
            }
            if(maxBounds.x == Number.NEGATIVE_INFINITY || maxBounds.x == 0)
            {
               maxBounds.x = param3 * 0.5;
            }
         }
         if(param2 == 0)
         {
            if(minBounds.y == Number.POSITIVE_INFINITY || minBounds.y == 0)
            {
               minBounds.y = -(param3 * 0.5);
            }
            if(maxBounds.y == Number.NEGATIVE_INFINITY || maxBounds.y == 0)
            {
               maxBounds.y = param3 * 0.5;
            }
         }
         if(param1 < minBounds.x)
         {
            minBounds.x = param1;
         }
         else if(param1 > maxBounds.x)
         {
            maxBounds.x = param1;
         }
         if(param2 < minBounds.y)
         {
            minBounds.y = param2;
         }
         else if(param2 > maxBounds.y)
         {
            maxBounds.y = param2;
         }
         if(maxBounds.x == Number.NEGATIVE_INFINITY)
         {
            maxBounds.x = param1;
         }
         if(maxBounds.y == Number.NEGATIVE_INFINITY)
         {
            maxBounds.y = param2;
         }
         isInvalid = true;
         hasValidatedGeometry = false;
      }
      
      public function getVertexPosition(param1:int, param2:Point = null) : Point
      {
         var _loc3_:Point = param2;
         if(_loc3_ == null)
         {
            _loc3_ = new Point();
         }
         _loc3_.x = this._line[param1].x;
         _loc3_.y = this._line[param1].y;
         return _loc3_;
      }
      
      override protected function buildGeometry() : void
      {
         this.buildGeometryPreAllocatedVectors();
      }
      
      protected function buildGeometryOriginal() : void
      {
         if(this._line == null || this._line.length == 0)
         {
            return;
         }
         vertices.length = 0;
         indices.length = 0;
         var _loc1_:int = 0;
         var _loc2_:int = int(vertices.length);
         var _loc3_:Number = 1 / VERTEX_STRIDE;
         this._numVertices = this._line.length;
         createPolyLine(this._line,vertices,indices,_loc1_);
         _loc1_ += (vertices.length - _loc2_) * _loc3_;
      }
      
      protected function buildGeometryPreAllocatedVectors() : void
      {
         if(this._line == null || this._line.length == 0)
         {
            return;
         }
         this._numVertices = this._line.length;
         vertices.length = 0;
         indices.length = 0;
         createPolyLinePreAlloc(this._line,vertices,indices,this._jointType);
      }
      
      override protected function shapeHitTestLocalInternal(param1:Number, param2:Number) : Boolean
      {
         var _loc5_:starling.display.graphics.StrokeVertex = null;
         var _loc6_:starling.display.graphics.StrokeVertex = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         if(this._line == null)
         {
            return false;
         }
         if(this._line.length < 2)
         {
            return false;
         }
         var _loc3_:int = int(this._line.length);
         var _loc4_:int = 1;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = this._line[_loc4_ - 1];
            _loc7_ = ((_loc6_ = this._line[_loc4_]).x - _loc5_.x) * (_loc6_.x - _loc5_.x) + (_loc6_.y - _loc5_.y) * (_loc6_.y - _loc5_.y);
            if(!((_loc8_ = ((param1 - _loc5_.x) * (_loc6_.x - _loc5_.x) + (param2 - _loc5_.y) * (_loc6_.y - _loc5_.y)) / _loc7_) < 0 || _loc8_ > 1))
            {
               _loc9_ = _loc5_.x + _loc8_ * (_loc6_.x - _loc5_.x);
               _loc10_ = _loc5_.y + _loc8_ * (_loc6_.y - _loc5_.y);
               _loc11_ = (param1 - _loc9_) * (param1 - _loc9_) + (param2 - _loc10_) * (param2 - _loc10_);
               _loc12_ = (_loc12_ = _loc5_.thickness * (1 - _loc8_) + _loc6_.thickness * _loc8_) + _precisionHitTestDistance;
               if(_loc11_ <= _loc12_ * _loc12_)
               {
                  return true;
               }
            }
            _loc4_++;
         }
         return false;
      }
      
      public function localToParent(param1:Point, param2:Point = null) : Point
      {
         return MatrixUtil.transformCoords(transformationMatrix,param1.x,param1.y,param2);
      }
   }
}

import flash.geom.Point;
import flash.geom.Rectangle;

class StrokeCollisionHelper
{
    
   
   public var localPT1:Point;
   
   public var localPT2:Point;
   
   public var localPT3:Point;
   
   public var localPT4:Point;
   
   public var globalPT1:Point;
   
   public var globalPT2:Point;
   
   public var globalPT3:Point;
   
   public var globalPT4:Point;
   
   public var bounds1:flash.geom.Rectangle;
   
   public var bounds2:flash.geom.Rectangle;
   
   public var testIntersectPoint:Point;
   
   public var s1v0Vector:Vector.<Point> = null;
   
   public var s1v1Vector:Vector.<Point> = null;
   
   public var s2v0Vector:Vector.<Point> = null;
   
   public var s2v1Vector:Vector.<Point> = null;
   
   public function StrokeCollisionHelper()
   {
      this.localPT1 = new Point();
      this.localPT2 = new Point();
      this.localPT3 = new Point();
      this.localPT4 = new Point();
      this.globalPT1 = new Point();
      this.globalPT2 = new Point();
      this.globalPT3 = new Point();
      this.globalPT4 = new Point();
      this.bounds1 = new flash.geom.Rectangle();
      this.bounds2 = new flash.geom.Rectangle();
      this.testIntersectPoint = new Point();
      super();
   }
}
