using Microsoft.Data.Sqlite;

using var connection = new SqliteConnection("Data Source=:memory:");
connection.Open();

using var command = connection.CreateCommand();
command.CommandText = "select sqlite_version()";
Console.WriteLine($"OK: SQLite {command.ExecuteScalar()}");
