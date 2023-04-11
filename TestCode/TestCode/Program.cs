using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;

using System.Reflection;
using System.Text;

namespace TestCode
{
    public static class Program
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

        public static int largest(int[] Array)
        {
            var maxNumber = 0;

            if (Array != null)
            {
                for (int i = 0; i < Array.Length; i++)
                {
                    if (maxNumber < Array[i])
                        maxNumber = Array[i];
                }
            }

            return maxNumber;
        }
        public static void BreakLoop()
        {
            var res = "before";
            for (int i = 5; i < 12; i++)
          {              
                Console.WriteLine(i);
                if (i == 10)
                {
                    res = "InLoop";
                    break;
                }              
            };
            Console.WriteLine(res);
        }
        public static void ReaminQty()
        {
            var remainqty = 500;
            while (remainqty != 0)
            {
                remainqty = ReturnQty(remainqty);
               if (remainqty == 0) break;
                Console.WriteLine(remainqty);
            }
        }
        public static int ReturnQty(int remainqty)
        {

            return (remainqty - 50);
        }
        public static int CheckException()
        {
            object o2 = null;
            try
            {
                int i2 = (int)o2;   // Error
            }
            catch (InvalidCastException e)
            {
                // recover from exception
            }
            return 0;
        } 

        public static int ReadBinary()
        {
            var bytes = Encoding.UTF8.GetBytes("test");

            var t= Encoding.UTF8.GetString(bytes);
        
            //cmdb.Parameters.AddWithValue("@text", Encoding.UTF8.GetBytes(textreview.Text));

           //var tst = Encoding.GetString((byte[])bytes);

            return 0;

        }
      
        static void Main(string[] args)
        {
            int[] a = { 1, 3, 5, 7 };

            //for(int i=0; i <= a.Length-1; i++)
            //{
            //    Console.Write($"Array,{a[i]}");
            //}
            //foreach(var item in a)
            //{
            //    Console.WriteLine(item);
            //}
            ////Console.WriteLine("Hello World!");
            ///
            //test();
            //var red = test2();

            //foreach (dynamic item in red)
            //{
            //    Console.WriteLine("test" + item);
            //}

            //int maxNumber = largest(a);
            //Console.WriteLine(maxNumber);
            //ModelCRUD model = new ModelCRUD();
            //model.num = 2;
            //model.Code = "0032";
            //CRUD.Savevalue(model);
            ReaminQty();
            //BreakLoop();
            //var test = new List<dynamic>();

            //List <string[]> list= new List<string[]>();

            //var test1 = new List<TestModel>()
            //{
            //    new TestModel{ id=15}
            //};

            //DateTime localDate = DateTime.Now;

            //var t= ToDataTable(test1);

            //int Timestamp = (int)DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1)).TotalSeconds;

            //Console.WriteLine(localDate.ToString());
            //Console.WriteLine(Timestamp);
            //CheckException();
            ReadBinary();
        }

        public static DataTable ToDataTable<T>(this IList<T> list)
        {
            PropertyDescriptorCollection props = TypeDescriptor.GetProperties(typeof(T));
            DataTable table = new DataTable();
            for (int i = 0; i < props.Count; i++)
            {
                PropertyDescriptor prop = props[i];
                table.Columns.Add(prop.Name, Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType);
            }
            object[] values = new object[props.Count];
            foreach (T item in list)
            {
                for (int i = 0; i < values.Length; i++)
                    values[i] = props[i].GetValue(item) ?? DBNull.Value;
                table.Rows.Add(values);
            }
            return table;
        }



    }

    public class TestModel
    {
        public int? id { get; set; }
      
    }

}
