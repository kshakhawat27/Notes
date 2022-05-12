using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;

namespace TestCode
{
    class CRUD
    {
        public static int Savevalue(ModelCRUD model)
        {
            int? a = 0;
            try
            {

                if (a.HasValue && !string.IsNullOrEmpty(model.Code))
                {
                    model.num = model.num ?? 0;
                    Console.Write(model.num + "Code is Empty");
                }
                else {

                    throw new InvalidProgramException("Successfull Error");
                }

            }
            catch (Exception ex)
            {
                Console.Write("Error");
            }

             return 1;
        }
      
    }

    class ModelCRUD
    {
        public Nullable<int> num { get; set; }
        public string Code { get; set; }
    }
}
