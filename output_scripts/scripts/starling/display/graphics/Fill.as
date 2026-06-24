package starling.display.graphics
{
   import flash.geom.Matrix;
   import starling.display.graphics.util.TriangleUtil;
   
   public class Fill extends starling.display.graphics.GraphicRenderer
   {
      
      public static const VERTEX_STRIDE:int = 9;
      
      private static var lastVertex:Vector.<Number>;
      
      private static var lastColor:uint;
      
      private static var r:Number;
      
      private static var g:Number;
      
      private static var b:Number;
      
      private static var node:starling.display.graphics.VertexList;
      
      private static var iter:int;
      
      private static var flag:Boolean;
      
      private static var currentNode:starling.display.graphics.VertexList;
      
      private static var n0:starling.display.graphics.VertexList;
      
      private static var n1:starling.display.graphics.VertexList;
      
      private static var n2:starling.display.graphics.VertexList;
      
      private static var v0x:Number;
      
      private static var v0y:Number;
      
      private static var v1x:Number;
      
      private static var v1y:Number;
      
      private static var v2x:Number;
      
      private static var v2y:Number;
      
      private static var outputIndicesLen:int;
      
      private static var currentList:starling.display.graphics.VertexList;
      
      private static var openList:Vector.<starling.display.graphics.VertexList>;
      
      private static var startNode:starling.display.graphics.VertexList;
      
      private static var n:starling.display.graphics.VertexList;
      
      private static var found:Boolean;
      
      private static var output:Vector.<starling.display.graphics.VertexList>;
      
      private static var outputLength:int;
      
      private static var headA:starling.display.graphics.VertexList;
      
      private static var nodeA:starling.display.graphics.VertexList;
      
      private static var isSimple:Boolean;
      
      private static var nodeB:starling.display.graphics.VertexList;
      
      private static var temp:starling.display.graphics.VertexList;
      
      private static var isectNodeA:starling.display.graphics.VertexList;
      
      private static var headB:starling.display.graphics.VertexList;
      
      private static var isectNodeB:starling.display.graphics.VertexList;
      
      private static var i:int;
      
      private static var len:int;
      
      private static var index:int;
      
      private static var olen:int;
      
      private static var vertexList:starling.display.graphics.VertexList;
      
      private static var wn:int;
      
      private static var isUp:Boolean;
      
      protected static const EPSILON:Number = 0.000001;
      
      private static var intersecionVector:Vector.<Number> = new Vector.<Number>();
      
      private static var intersectionLen:int = 0;
      
      private static var ux:Number;
      
      private static var uy:Number;
      
      private static var vx:Number;
      
      private static var vy:Number;
      
      private static var wx:Number;
      
      private static var wy:Number;
      
      private static var D:Number = ux * vy - uy * vx;
      
      private static var t:Number;
      
      private static var t2:Number;
      
      private static var vertexA:Vector.<Number>;
      
      private static var vertexB:Vector.<Number>;
       
      
      protected var fillVertices:starling.display.graphics.VertexList;
      
      protected var _numVertices:int;
      
      protected var _isConvex:Boolean = true;
      
      public function Fill()
      {
         super();
         _uvMatrix = new Matrix();
         _uvMatrix.scale(1 / 256,1 / 256);
         indices = new Vector.<uint>();
         vertices = new Vector.<Number>();
      }
      
      protected static function triangulate(param1:starling.display.graphics.VertexList, param2:int, param3:Vector.<Number>, param4:Vector.<uint>, param5:Boolean) : void
      {
         param1 = starling.display.graphics.VertexList.clone(param1);
         openList = null;
         if(param5 == false)
         {
            openList = convertToSimple(param1);
         }
         else
         {
            openList = new Vector.<starling.display.graphics.VertexList>();
            openList[0] = param1;
         }
         flatten(openList,param3);
         while(openList.length > 0)
         {
            currentList = openList.pop();
            if(isClockWise(currentList) == false)
            {
               starling.display.graphics.VertexList.reverse(currentList);
            }
            iter = 0;
            flag = false;
            currentNode = currentList.head;
            while(iter <= param2 * 3)
            {
               ++iter;
               n0 = currentNode.prev;
               n1 = currentNode;
               n2 = currentNode.next;
               if(n2.next == n0)
               {
                  param4.push(n0.index,n1.index,n2.index);
                  starling.display.graphics.VertexList.releaseNode(n0);
                  starling.display.graphics.VertexList.releaseNode(n1);
                  starling.display.graphics.VertexList.releaseNode(n2);
                  break;
               }
               v0x = n0.vertex[0];
               v0y = n0.vertex[1];
               v1x = n1.vertex[0];
               v1y = n1.vertex[1];
               v2x = n2.vertex[0];
               v2y = n2.vertex[1];
               if(isReflex(v0x,v0y,v1x,v1y,v2x,v2y) == false)
               {
                  currentNode = currentNode.next;
               }
               else
               {
                  startNode = n2.next;
                  n = startNode;
                  found = false;
                  while(n != n0)
                  {
                     if(TriangleUtil.isPointInTriangle(v0x,v0y,v1x,v1y,v2x,v2y,n.vertex[0],n.vertex[1]))
                     {
                        found = true;
                        break;
                     }
                     n = n.next;
                  }
                  if(found)
                  {
                     currentNode = currentNode.next;
                  }
                  else
                  {
                     outputIndicesLen = param4.length;
                     var _loc6_:*;
                     param4[_loc6_ = outputIndicesLen++] = n0.index;
                     var _loc7_:*;
                     param4[_loc7_ = outputIndicesLen++] = n1.index;
                     var _loc8_:*;
                     param4[_loc8_ = outputIndicesLen++] = n2.index;
                     if(n1 == n1.head)
                     {
                        n1.vertex = n2.vertex;
                        n1.next = n2.next;
                        n1.index = n2.index;
                        n1.next.prev = n1;
                        starling.display.graphics.VertexList.releaseNode(n2);
                     }
                     else
                     {
                        n0.next = n2;
                        n2.prev = n0;
                        starling.display.graphics.VertexList.releaseNode(n1);
                     }
                     currentNode = n0;
                  }
               }
            }
            starling.display.graphics.VertexList.dispose(currentList);
         }
      }
      
      protected static function convertToSimple(param1:starling.display.graphics.VertexList) : Vector.<starling.display.graphics.VertexList>
      {
         output = new Vector.<starling.display.graphics.VertexList>();
         outputLength = 0;
         openList = new Vector.<starling.display.graphics.VertexList>();
         openList.push(param1);
         while(openList.length > 0)
         {
            currentList = openList.pop();
            headA = currentList.head;
            nodeA = headA;
            isSimple = true;
            if(nodeA.next == nodeA || nodeA.next.next == nodeA || nodeA.next.next.next == nodeA)
            {
               var _loc2_:* = outputLength++;
               output[_loc2_] = headA;
            }
            else
            {
               do
               {
                  nodeB = nodeA.next.next;
                  do
                  {
                     intersecionVector.length = 0;
                     if(intersection(nodeA,nodeA.next,nodeB,nodeB.next,intersecionVector))
                     {
                        isSimple = false;
                        temp = nodeA.next;
                        isectNodeA = starling.display.graphics.VertexList.getNode();
                        i = 0;
                        len = intersecionVector.length;
                        while(i < len)
                        {
                           isectNodeA.vertex[i] = intersecionVector[i];
                           ++i;
                        }
                        isectNodeA.prev = nodeA;
                        isectNodeA.next = nodeB.next;
                        isectNodeA.next.prev = isectNodeA;
                        isectNodeA.head = headA;
                        nodeA.next = isectNodeA;
                        headB = nodeB;
                        isectNodeB = starling.display.graphics.VertexList.getNode();
                        i = 0;
                        len = intersecionVector.length;
                        while(i < len)
                        {
                           isectNodeB.vertex[i] = intersecionVector[i];
                           ++i;
                        }
                        isectNodeB.prev = nodeB;
                        isectNodeB.next = temp;
                        isectNodeB.next.prev = isectNodeB;
                        isectNodeB.head = headB;
                        nodeB.next = isectNodeB;
                        do
                        {
                           nodeB.head = headB;
                           nodeB = nodeB.next;
                        }
                        while(nodeB != headB);
                        
                        openList[openList.length] = headA;
                        openList[openList.length] = headB;
                        break;
                     }
                     nodeB = nodeB.next;
                  }
                  while(nodeB != nodeA.prev && isSimple);
                  
                  nodeA = nodeA.next;
               }
               while(nodeA != headA && isSimple);
               
               if(isSimple)
               {
                  _loc2_ = outputLength++;
                  output[_loc2_] = headA;
               }
            }
         }
         return output;
      }
      
      protected static function flatten(param1:Vector.<starling.display.graphics.VertexList>, param2:Vector.<Number>) : void
      {
         len = param1.length;
         index = 0;
         olen;
         i = 0;
         while(i < len)
         {
            vertexList = param1[i];
            node = vertexList.head;
            do
            {
               node.index = index++;
               olen = param2.length;
               param2[olen] = node.vertex[0];
               var _loc3_:* = ++olen;
               param2[_loc3_] = node.vertex[1];
               var _loc4_:*;
               param2[_loc4_ = ++olen] = node.vertex[2];
               var _loc5_:*;
               param2[_loc5_ = ++olen] = node.vertex[3];
               var _loc6_:*;
               param2[_loc6_ = ++olen] = node.vertex[4];
               var _loc7_:*;
               param2[_loc7_ = ++olen] = node.vertex[5];
               var _loc8_:*;
               param2[_loc8_ = ++olen] = node.vertex[6];
               var _loc9_:*;
               param2[_loc9_ = ++olen] = node.vertex[7];
               var _loc10_:*;
               param2[_loc10_ = ++olen] = node.vertex[8];
               node = node.next;
            }
            while(node != node.head);
            
            ++i;
         }
      }
      
      protected static function windingNumberAroundPoint(param1:starling.display.graphics.VertexList, param2:Number, param3:Number) : int
      {
         wn = 0;
         node = param1.head;
         do
         {
            v0y = node.vertex[1];
            v1y = node.next.vertex[1];
            if(param3 > v0y && param3 < v1y || param3 > v1y && param3 < v0y)
            {
               v0x = node.vertex[0];
               v1x = node.next.vertex[0];
               isUp = v1y < param3;
               if(isUp)
               {
                  wn += (v1x - v0x) * (param3 - v0y) - (v1y - v0y) * (param2 - v0x) < 0 ? 1 : 0;
               }
               else
               {
                  wn += (v1x - v0x) * (param3 - v0y) - (v1y - v0y) * (param2 - v0x) < 0 ? 0 : -1;
               }
            }
            node = node.next;
         }
         while(node != param1.head);
         
         return wn;
      }
      
      public static function isClockWise(param1:starling.display.graphics.VertexList) : Boolean
      {
         wn = 0;
         node = param1.head;
         do
         {
            wn += (node.next.vertex[0] - node.vertex[0]) * (node.next.vertex[1] + node.vertex[1]);
            node = node.next;
         }
         while(node != param1.head);
         
         return wn <= 0;
      }
      
      protected static function windingNumber(param1:starling.display.graphics.VertexList) : int
      {
         wn = 0;
         node = param1.head;
         do
         {
            wn += (node.next.vertex[0] - node.vertex[0]) * (node.next.next.vertex[1] - node.vertex[1]) - (node.next.next.vertex[0] - node.vertex[0]) * (node.next.vertex[1] - node.vertex[1]) < 0 ? -1 : 1;
            node = node.next;
         }
         while(node != param1.head);
         
         return wn;
      }
      
      protected static function isReflex(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : Boolean
      {
         if(TriangleUtil.isLeft(param1,param2,param3,param4,param5,param6))
         {
            return false;
         }
         if(TriangleUtil.isLeft(param3,param4,param5,param6,param1,param2))
         {
            return false;
         }
         return true;
      }
      
      private static function intersection(param1:starling.display.graphics.VertexList, param2:starling.display.graphics.VertexList, param3:starling.display.graphics.VertexList, param4:starling.display.graphics.VertexList, param5:Vector.<Number>) : Boolean
      {
         ux = param2.vertex[0] - param1.vertex[0];
         uy = param2.vertex[1] - param1.vertex[1];
         vx = param4.vertex[0] - param3.vertex[0];
         vy = param4.vertex[1] - param3.vertex[1];
         wx = param1.vertex[0] - param3.vertex[0];
         wy = param1.vertex[1] - param3.vertex[1];
         D = ux * vy - uy * vx;
         if((D < 0 ? -D : D) < EPSILON)
         {
            return false;
         }
         t = (vx * wy - vy * wx) / D;
         if(t < 0 || t > 1)
         {
            return false;
         }
         t2 = (ux * wy - uy * wx) / D;
         if(t2 < 0 || t2 > 1)
         {
            return false;
         }
         vertexA = param1.vertex;
         vertexB = param2.vertex;
         intersectionLen = 0;
         var _loc6_:*;
         param5[_loc6_ = intersectionLen++] = vertexA[0] + t * (vertexB[0] - vertexA[0]);
         var _loc7_:*;
         param5[_loc7_ = intersectionLen++] = vertexA[1] + t * (vertexB[1] - vertexA[1]);
         var _loc8_:*;
         param5[_loc8_ = intersectionLen++] = 0;
         var _loc9_:*;
         param5[_loc9_ = intersectionLen++] = vertexA[3] + t * (vertexB[3] - vertexA[3]);
         var _loc10_:*;
         param5[_loc10_ = intersectionLen++] = vertexA[4] + t * (vertexB[4] - vertexA[4]);
         var _loc11_:*;
         param5[_loc11_ = intersectionLen++] = vertexA[5] + t * (vertexB[5] - vertexA[5]);
         var _loc12_:*;
         param5[_loc12_ = intersectionLen++] = vertexA[6] + t * (vertexB[6] - vertexA[6]);
         var _loc13_:*;
         param5[_loc13_ = intersectionLen++] = vertexA[7] + t * (vertexB[7] - vertexA[7]);
         var _loc14_:*;
         param5[_loc14_ = intersectionLen++] = vertexA[8] + t * (vertexB[8] - vertexA[8]);
         return true;
      }
      
      public function get numVertices() : int
      {
         return this._numVertices;
      }
      
      public function clear() : void
      {
         indices.length = 0;
         vertices.length = 0;
         if(minBounds)
         {
            minBounds.x = minBounds.y = 0;
            maxBounds.x = maxBounds.y = 0;
         }
         this._numVertices = 0;
         starling.display.graphics.VertexList.releaseNode(this.fillVertices);
         this.fillVertices = null;
         setGeometryInvalid();
         this._isConvex = true;
      }
      
      override public function dispose() : void
      {
         this.clear();
         this.fillVertices = null;
         super.dispose();
      }
      
      public function addDegenerates(param1:Number, param2:Number, param3:uint = 16777215, param4:Number = 1) : void
      {
         if(this._numVertices < 1)
         {
            return;
         }
         lastVertex = this.fillVertices.prev.vertex;
         lastColor = uint(lastVertex[3] * 255) << 16;
         lastColor |= uint(lastVertex[4] * 255) << 8;
         lastColor |= uint(lastVertex[5] * 255);
         this.addVertex(lastVertex[0],lastVertex[1],lastColor,lastVertex[6]);
         this.addVertex(param1,param2,param3,param4);
      }
      
      public function addVertexInConvexShape(param1:Number, param2:Number, param3:uint = 16777215, param4:Number = 1) : void
      {
         this.addVertexInternal(param1,param2,param3,param4);
      }
      
      public function addVertex(param1:Number, param2:Number, param3:uint = 16777215, param4:Number = 1) : void
      {
         this._isConvex = false;
         this.addVertexInternal(param1,param2,param3,param4);
      }
      
      protected function addVertexInternal(param1:Number, param2:Number, param3:uint = 16777215, param4:Number = 1) : void
      {
         r = (param3 >> 16) / 255;
         g = ((param3 & 65280) >> 8) / 255;
         b = (param3 & 255) / 255;
         node = starling.display.graphics.VertexList.getNode();
         if(this._numVertices == 0)
         {
            this.fillVertices = node;
            node.head = node;
            node.prev = node;
         }
         node.next = this.fillVertices.head;
         node.prev = this.fillVertices.head.prev;
         node.prev.next = node;
         node.next.prev = node;
         node.index = this._numVertices;
         node.vertex[0] = param1;
         node.vertex[1] = param2;
         node.vertex[2] = 0;
         node.vertex[3] = r;
         node.vertex[4] = g;
         node.vertex[5] = b;
         node.vertex[6] = param4;
         node.vertex[7] = param1;
         node.vertex[8] = param2;
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
         ++this._numVertices;
         setGeometryInvalid();
      }
      
      override protected function buildGeometry() : void
      {
         if(this._numVertices < 3)
         {
            return;
         }
         vertices.length = 0;
         indices.length = 0;
         triangulate(this.fillVertices,this._numVertices,vertices,indices,this._isConvex);
      }
      
      override public function shapeHitTest(param1:Number, param2:Number) : Boolean
      {
         if(vertices == null)
         {
            return false;
         }
         if(this.numVertices < 3)
         {
            return false;
         }
         shapeHitTestPoint.x = param1;
         shapeHitTestPoint.y = param2;
         globalToLocal(shapeHitTestPoint,shapeHitTestResultPoint);
         wn = windingNumberAroundPoint(this.fillVertices,shapeHitTestResultPoint.x,shapeHitTestResultPoint.y);
         if(isClockWise(this.fillVertices))
         {
            return wn != 0;
         }
         return wn == 0;
      }
      
      override protected function shapeHitTestLocalInternal(param1:Number, param2:Number) : Boolean
      {
         wn = windingNumberAroundPoint(this.fillVertices,param1,param2);
         if(isClockWise(this.fillVertices))
         {
            return wn != 0;
         }
         return wn == 0;
      }
   }
}
