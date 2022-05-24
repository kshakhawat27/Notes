using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using TestApp.Models;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using System.Net.Http.Headers;
using System.IO;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Text;
using NPOI.XSSF.UserModel;
using NPOI.HSSF.UserModel;
using Newtonsoft.Json;
using NPOI.SS.UserModel;
using OfficeOpenXml;
using System.Linq;


// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TestApp.Controllers
{
    public class EmployeeController : Controller
    {
        private IHostingEnvironment _env;
        EmployeeDataAccessLayer objemployee = new EmployeeDataAccessLayer();

        public EmployeeController(IHostingEnvironment env)
        {
            _env = env;
        }
        [HttpGet]
        [Route("api/Employee/Index")]
        public IEnumerable<TblEmployee> Index()
        {
            return objemployee.GetAllEmployees();
        }

        [HttpPost]
        [Route("api/Employee/Create")]
        public TblEmployee Create(TblEmployee employee)
        {
            return objemployee.AddEmployee(employee);
        }

        [HttpGet]
        //[Route("api/Employee/Details/{id}")]
        [Route("api/Employee/Details")]
        public TblEmployee Details(int id)
        {
            return objemployee.GetEmployeeData(id);
        }

        [HttpPut]
        [Route("api/Employee/Edit")]
        public int Edit(TblEmployee employee)
        {
            return objemployee.UpdateEmployee(employee);
        }

        [HttpDelete]
        [Route("api/Employee/Delete/{id}")]
        public int Delete(int id)
        {
            return objemployee.DeleteEmployee(id);
        }

        [HttpGet]
        [Route("api/Employee/GetCityList")]
        public IEnumerable<TblCities> Details()
        {
            return objemployee.GetCities();
        }

        [HttpPost]
        [Route("api/Employee/ImportExcelFile")]
        //public IActionResult ValidateFile()
        //{
        //    IFormFile files = Request.Form.Files[0];

        //    List<TblEmployee> user = new List<TblEmployee>(); 

        //    using (var stream = new MemoryStream())
        //    {
        //        files.CopyToAsync(stream);

        //        using (var package = new ExcelPackage(stream))
        //        {
        //            ExcelWorksheet worksheet = package.Workbook.Worksheets["Sheet1"];

        //            var rowCount = worksheet.Dimension.Rows;

        //            for (int i = 2; i <= rowCount; i++)
        //            {
        //                user.Add(new TblEmployee
        //                {
        //                    Name = worksheet.Cells[i, 1].Value.ToString().Trim(),
        //                }) ;
        //            }              
        //        }
        //        TblEmployee emp = new TblEmployee();

        //        foreach (TblEmployee employee in user)
        //        {
        //            objemployee.AddEmployee(employee);
        //        }

        //    }
        //    return Json(null);
        //}

        public async Task<ActionResult> ImportExcelFile()
        {
            if (Request.Form.Files == null || Request.Form.Files.Count <= 0)            
                return Ok("Not done");//should be returned validation message            

            var requestFile = Request.Form.Files[0];

            //var webRootPath = _env.WebRootPath;
            //string folderName = "Upload";
            //string newPath = Path.Combine(webRootPath, folderName);
            //StringBuilder sb = new StringBuilder();
            //if (!Directory.Exists(newPath))
            //    Directory.CreateDirectory(newPath);

            //if (!Directory.Exists(newPath))
            //{
            //    Directory.CreateDirectory(newPath);
            //}


            string sFileExtension = Path.GetExtension(requestFile.FileName).ToLower();
            ISheet sheet;
            //string fullPath = Path.Combine(newPath, requestFile.FileName);

            //using (var stream = new FileStream(fullPath, FileMode.Create))
            //{
            using (var stream = new MemoryStream())
            {
                requestFile.CopyTo(stream);
                stream.Position = 0;

                if (sFileExtension == ".xls")//This will read the Excel 97-2000 formats    
                {
                    HSSFWorkbook hssfwb = new HSSFWorkbook(stream);
                    sheet = hssfwb.GetSheetAt(0);
                }
                else //This will read 2007 Excel format    
                {
                    XSSFWorkbook hssfwb = new XSSFWorkbook(stream);
                    sheet = hssfwb.GetSheetAt(0);
                }

                IRow headerRow = sheet.GetRow(0);
                int cellCount = headerRow.LastCellNum;

                for (int i = (sheet.FirstRowNum + 1); i <= sheet.LastRowNum; i++) //Read Excel File 
                {
                    IRow row = sheet.GetRow(i);
                    if (row == null) continue;
                    if (row.Cells.All(d => d.CellType == CellType.Blank)) continue;

                    TblEmployee employee = new TblEmployee()
                    {
                        Name = (row.Cells[0].ToString()),
                    };

                    objemployee.AddEmployee(employee);
                }
            }

            return Ok("done");
        }

    }
}
