using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;

namespace TestApp.Models
{
    public partial class TblEmployee
    {
        public int EmployeeId { get; set; }
        public string Name { get; set; }
        public string City { get; set; }
        public string Department { get; set; }
        public string Gender { get; set; }
    }
    public class FileUploadViewModel
    {
        public string name_x { get; set; }
        public IFormFile excel_x { get; set; }
    }

    public class User
    {
        public string Name { get; set; }

        public int Age { get; set; }
        public string Gender { get; set; }

    }
}
