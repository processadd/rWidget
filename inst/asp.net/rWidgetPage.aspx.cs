using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json;

namespace RWidget
{
    public partial class rWidgetPage : System.Web.UI.Page
    {
        static readonly string connString = string.Format("Data Source={0};Initial Catalog={1};Integrated Security=SSPI;", @".\sql2016", "rWidget");

        [System.Web.Services.WebMethod]
        public static IEnumerable<string> ShowWidgets()
        {
            string jsonData = GetData();
            IEnumerable<string> s = GetWidgets(jsonData, "rWidgetDemo");
            return s;
        }

        static string GetData()
        {
            string json = string.Empty;
            using (var conn = new SqlConnection(connString))
            {
                conn.Open();
                string cmdString = string.Empty;
                var cmd = new SqlCommand("SELECT [Date], APPL, MSFT FROM dygraphs_closePrices", conn);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader != null)
                {
                    var dt = new DataTable();
                    dt.Load(reader);
                    json = JsonConvert.SerializeObject(dt);
                }
            }

            return json;
        }

        static IEnumerable<string> GetWidgets(string jsonData, string spName)
        {
            using (var conn = new SqlConnection(connString))
            {
                conn.Open();
                string cmdText = string.Format(@"EXECUTE {0} '{1}', '{2}', '{3}', '{4}'", spName, jsonData, "scripts", "dygraphs", "DT");
                var cmd = new SqlCommand(cmdText, conn);
                SqlDataReader reader = cmd.ExecuteReader();

                var divs = new List<string>();
                while (reader.Read())
                {
                    divs.Add(reader[0].ToString());
                    divs.Add(reader[1].ToString());
                }

                return divs;
            }
        }
    }
}