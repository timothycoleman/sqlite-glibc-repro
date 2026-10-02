# Microsoft.Data.Sqlite 10.0.11+ fails to load on RHEL 8 (GLIBC_2.33 not found)

Description:

Microsoft.Data.Sqlite `10.0.11+` doesn't work on RHEL 8, although RHEL 8 is supported by .NET 10

Reproduction:

```
docker build -t sqlite-glibc-repro .
docker run --rm sqlite-glibc-repro
```

Expected output:

```
OK: SQLite
```

Actual output:

```
Unhandled exception. System.TypeInitializationException: The type initializer for 'Microsoft.Data.Sqlite.SqliteConnection' threw an exception.
 ---> System.Reflection.TargetInvocationException: Exception has been thrown by the target of an invocation.
 ---> System.DllNotFoundException: Unable to load shared library 'e_sqlite3' or one of its dependencies. In order to help diagnose loading problems, consider using a tool like strace. If you're using glibc, consider setting the LD_DEBUG environment variable:
/app/e_sqlite3.so: cannot open shared object file: No such file or directory
/lib64/libc.so.6: version `GLIBC_2.33' not found (required by /app/libe_sqlite3.so)
libe_sqlite3.so: cannot open shared object file: No such file or directory
/app/e_sqlite3: cannot open shared object file: No such file or directory
/app/libe_sqlite3: cannot open shared object file: No such file or directory

   at SQLitePCL.SQLite3Provider_e_sqlite3.NativeMethods.sqlite3_libversion_number()
   at SQLitePCL.SQLite3Provider_e_sqlite3.NativeMethods.sqlite3_libversion_number()
   at SQLitePCL.SQLite3Provider_e_sqlite3.SQLitePCL.ISQLite3Provider.sqlite3_libversion_number()
   at SQLitePCL.raw.SetProvider(ISQLite3Provider imp)
   at SQLitePCL.Batteries_V2.Init()
   at System.Reflection.MethodBaseInvoker.InterpretedInvoke_Method(Object obj, IntPtr* args)
   at System.Reflection.MethodBaseInvoker.InvokeWithNoArgs(Object obj, BindingFlags invokeAttr)
   --- End of inner exception stack trace ---
   at System.Reflection.MethodBaseInvoker.InvokeWithNoArgs(Object obj, BindingFlags invokeAttr)
   at System.Reflection.RuntimeMethodInfo.Invoke(Object obj, BindingFlags invokeAttr, Binder binder, Object[] parameters, CultureInfo culture)
   at Microsoft.Data.Sqlite.SqliteConnection..cctor()
   --- End of inner exception stack trace ---
   at Microsoft.Data.Sqlite.SqliteConnection..ctor(String connectionString)
   at Program.<Main>$(String[] args) in /src/Program.cs:line 3
```

Cause:

Starting with Microsoft.Data.Sqlite `10.0.11`, which depends on SQLitePCLRaw `2.1.12`, the bundled
`linux-x64` native library `libe_sqlite3.so` needs a higher version of glibc than ships in RHEL 8.

RHEL 8 ships glibc 2.28 and is a [supported OS for .NET 10](https://learn.microsoft.com/dotnet/core/install/linux-rhel#supported-distributions).
So a .NET 10 servicing update of Microsoft.Data.Sqlite stops working on a supported platform.

Related SQLitePCL.raw issue: https://github.com/ericsink/SQLitePCL.raw/issues/674.

Changing the referenced version of Microsoft.Data.Sqlite in the repro to `10.0.10` makes it work as expected.
