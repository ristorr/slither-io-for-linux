package gaim
{
   public class FoodDeadpool
   {
       
      
      public var os:Vector.<gaim.Food>;
      
      public var len:int = 0;
      
      public var end_pos:int = 0;
      
      public function FoodDeadpool()
      {
         this.os = new Vector.<gaim.Food>();
         super();
      }
      
      public function add(param1:gaim.Food) : *
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
      
      public function get() : gaim.Food
      {
         var _loc1_:gaim.Food = null;
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
