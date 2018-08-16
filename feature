category..

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using TrainingProject.Models;
using TrainingProject.Helper;

namespace TrainingProject.Controllers
{
    public class CategoryController : Controller
    {
        // GET: Category                
        ConnectionHelper sqlconnect = new ConnectionHelper();

        [HttpGet]
        public ActionResult Detail(int? id)
        {
            CategoryModel category = new CategoryModel();
            if (id != null)
            {
                List<KeyValuePair<string, object>> param = new List<KeyValuePair<string, object>>();
                param.Add(new KeyValuePair<string, object>("CategoryId", id));
                var command_select = sqlconnect.CreateResult(executeType: ExecuteEnum.Detail ,query: "Training_selectCategory",command: CommandType.StoredProcedure, valuePairs: param);
                command_select.Read();
                {
                    category.CategoryID = Convert.ToInt32(command_select["CategoryID"]);
                    category.CategoryName = Convert.ToString(command_select["CategoryName"]);
                    category.CategoryDescription = Convert.ToString(command_select["CategoryDescription"]);
                    category.IsActive = Convert.ToBoolean(command_select["IsActive"]);
                    category.CreatedBy = Convert.ToInt32(command_select["CreatedBy"]);
                    category.CreatedDate = Convert.ToDateTime(command_select["CreatedDate"]);
                    category.ModifiedBy = command_select["ModifiedBy"] != null ? Convert.ToInt32(command_select["ModifiedBy"]) : 0;
                    category.ModifiedDate = command_select["ModifiedDate"] != null ? Convert.ToDateTime(command_select["ModifiedDate"]) : default(DateTime);
                }
            }
            return View("InsertCategory", category);
        }

        [HttpPost]
        public ActionResult InsertCategory(CategoryModel category)
        {
            var userlogin = Session["user"] as LoginModel;
            List<KeyValuePair<string, object>> param = new List<KeyValuePair<string, object>>();
            param.Add(new KeyValuePair<string, object>("CategoryName", category.CategoryName));
            param.Add(new KeyValuePair<string, object>("CategoryDescription", category.CategoryDescription));
            param.Add(new KeyValuePair<string, object>("IsActive", category.IsActive));
            
            if (category.CategoryID == 0)
            {
                category.CreatedUser = userlogin.Username;
                param.Add(new KeyValuePair<string, object>("CreatedBy", userlogin.UserID));
                param.Add(new KeyValuePair<string, object>("CreatedDate", DateTime.Now));
                
                TempData["Message_CategoryInsert"] = "category added.";
            }
            else
            {
                param.Add(new KeyValuePair<string, object>("CategoryID", category.CategoryID));
                param.Add(new KeyValuePair<string, object>("ModifiedBy", userlogin.UserID));
                param.Add(new KeyValuePair<string, object>("ModifiedDate", DateTime.Now));

                TempData["Message_CategoryUpdate"] = "category updated.";
            }
            var command_insert = sqlconnect.CreateResult(executeType: ExecuteEnum.Insert, query: "Training_insertCategory", command: CommandType.StoredProcedure, valuePairs: param);
            int result = command_insert;
            return RedirectToAction("Detail");
        }

        public ActionResult Listing(FormCollection coll)
        {
            string[] strSearch = new string[1];
            strSearch[0] = coll["txtSearch"];
            string searchView = coll["txtSearch"];
            ViewBag.searchQuery = searchView;
            List<KeyValuePair<string, object>> param = new List<KeyValuePair<string, object>>();
            param.Add(new KeyValuePair<string, object>("search", strSearch[0]));
            var cmd_search = sqlconnect.CreateResult(executeType:ExecuteEnum.List ,query: "Training_searchCategory", command: CommandType.StoredProcedure, valuePairs: param);

            return View("ListCategory", cmd_search);
        }

        public ActionResult Delete(int ID)
        {
            List<KeyValuePair<string, object>> param = new List<KeyValuePair<string, object>>();
            param.Add(new KeyValuePair<string, object>("CategoryID", ID));
            var cmd_delete = sqlconnect.CreateResult(executeType: ExecuteEnum.Delete ,query: "Training_deleteCategory", command: CommandType.StoredProcedure, valuePairs: param);
            int del_user = cmd_delete;

            return RedirectToAction("Listing");
        }
    }
}





connecttion helper

using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using TrainingProject.Models;
using TrainingProject.Helper;

namespace TrainingProject.Helper
{
    public class ConnectionHelper
    {
        SqlConnection connection;
        public static string strConnect = ConfigurationManager.ConnectionStrings["dataConnect"].ConnectionString;

        public ConnectionHelper()
        {
            connection = new SqlConnection(strConnect);
        }
        
        private SqlCommand CreateCommand(string cmdstring, CommandType type, List<KeyValuePair<string,object>> parameters)
        {
            SqlCommand cmd = new SqlCommand(cmdstring, connection);
            if(connection.State != ConnectionState.Open)
            {
                connection.Open();
            }
            cmd.CommandType = type;
            foreach (var item in parameters)
            {
                cmd.Parameters.AddWithValue("@"+item.Key, item.Value);
            }
            return cmd;
        }

        public dynamic CreateResult(ExecuteEnum executeType ,string query, CommandType command, List<KeyValuePair<string, object>> valuePairs)
        {
            var result_command = CreateCommand(cmdstring: query, type: command, parameters: valuePairs);
            if(executeType == ExecuteEnum.Insert)
            {
                int insertVal = result_command.ExecuteNonQuery();
                return insertVal;
            }
            if(executeType == ExecuteEnum.Delete)
            {
                int deleteVal = result_command.ExecuteNonQuery();
                return deleteVal;
            }
            if(executeType == ExecuteEnum.List)
            {
                DataTable searchResult = new DataTable();
                SqlDataAdapter adapter_search = new SqlDataAdapter(result_command);
                adapter_search.Fill(searchResult);
                return searchResult;
            }
            if(executeType == ExecuteEnum.Detail)
            {
                SqlDataReader reader = result_command.ExecuteReader();                
                return reader;
            }
            return null;
        }
    }

}



















execute enums
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TrainingProject.Helper
{
    public enum ExecuteEnum
    {
        Detail,
        Insert,
        Delete,
        List
    }
}




web comgig

<configuration>
  <connectionStrings>
    <add name="dataConnect" 
         connectionString="Data Source=172.20.21.129; MultipleActiveResultSets=True; Initial Catalog=RHPM; User ID=RHPM; Password=evry@123;"
         providerName="System.Data.SqlClient"/>
  </connectionStrings>
  <appSettings>
    <add key="webpages:Version" value="3.0.0.0" />
    <add key="webpages:Enabled" value="false" />
    <add key="ClientValidationEnabled" value="true" />
    <add key="UnobtrusiveJavaScriptEnabled" value="true" />
  </appSettings>
