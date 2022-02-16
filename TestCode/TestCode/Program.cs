using System;
using System.Collections.Generic;

namespace TestCode
{
    class Program
    {
        public static int test()
        {
            Console.WriteLine("red");
            return 1;
        }

        public static List<dynamic> test2()
        {
            List<dynamic> red = new List<dynamic>();

            red.Add("Test1");
            red.Add("Test2");

            var test = new TestModel();

            return red;

        
        }

        public static int largest(int [] Array)
        {
            var maxNumber=0;

            if(Array!=null)
            {
                for(int i=0;i<Array.Length;i++)
                {
                    if (maxNumber < Array[i])
                        maxNumber = Array[i];
                }
            }

            return maxNumber;
        }
        static void Main(string[] args)
        {
            //int[] a = { 1, 3, 5, 7 };
            //Console.WriteLine("Hello World!");
            //test();
            //var red = test2();

            //foreach (dynamic item in red)
            //{
            //    Console.WriteLine("test" + item);
            //}

            //int maxNumber = largest(a);
            //Console.WriteLine(maxNumber);
            ModelCRUD model = new ModelCRUD();
            model.num = 2;
            model.Code = "0032";
            CRUD.Savevalue(model);

        }


    }

    public class TestModel
    {
        public int? id { get; set; }
    }

}
