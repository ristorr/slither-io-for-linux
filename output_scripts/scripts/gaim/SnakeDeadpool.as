package gaim
{
   public class SnakeDeadpool
   {
       
      
      public var os:Vector.<gaim.Snake>;
      
      public var len:int = 0;
      
      public var end_pos:int = 0;
      
      public function SnakeDeadpool()
      {
         this.os = new Vector.<gaim.Snake>();
         super();
      }
      
      public function add(param1:gaim.Snake) : *
      {
         if(this.end_pos == this.len)
         {
            this.os.push(param1);
            ++this.len;
         }
         else
         {
            this.os[this.end_pos] = param1;
         }
         ++this.end_pos;
      }
      
      public function get() : gaim.Snake
      {
         var _loc1_:gaim.Snake = null;
         if(this.end_pos >= 1)
         {
            --this.end_pos;
            _loc1_ = this.os[this.end_pos];
            this.os[this.end_pos] = null;
            return _loc1_;
         }
         return null;
      }
   }
}
