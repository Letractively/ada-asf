-----------------------------------------------------------------------
--  asf-applications-tests -  ASF Application tests using ASFUnit
--  Copyright (C) 2011 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------

with AUnit.Test_Suites; use AUnit.Test_Suites;
with Util.Tests;
with Util.Beans.Basic;
with Util.Beans.Objects;
with Util.Beans.Methods;
with Ada.Strings.Unbounded;
with ASF.Models.Selects;

package ASF.Applications.Tests is

   use Ada.Strings.Unbounded;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   type Test is new Util.Tests.Test with null record;

   --  Initialize the test application
   overriding
   procedure Set_Up (T : in out Test);

   --  Test a GET request on a static file served by the File_Servlet.
   procedure Test_Get_File (T : in out Test);

   --  Test a GET 404 error on missing static file served by the File_Servlet.
   procedure Test_Get_404 (T : in out Test);

   --  Test a GET request on the measure servlet
   procedure Test_Get_Measures (T : in out Test);

   --  Test an invalid HTTP request.
   procedure Test_Invalid_Request (T : in out Test);

   --  Test a GET+POST request with submitted values and an action method called on the bean.
   procedure Test_Form_Post (T : in out Test);

   --  Test a POST request with an invalid submitted value
   procedure Test_Form_Post_Validation_Error (T : in out Test);

   --  Test a GET+POST request with form having <h:selectOneMenu> element.
   procedure Test_Form_Post_Select (T : in out Test);

   --  Test a POST request to invoke a bean method.
   procedure Test_Ajax_Action (T : in out Test);

   --  Test a POST request to invoke a bean method.
   --  Verify that invalid requests raise an error.
   procedure Test_Ajax_Action_Error (T : in out Test);

   type Form_Bean is new Util.Beans.Basic.Bean and Util.Beans.Methods.Method_Bean with record
      Name     : Unbounded_String;
      Password : Unbounded_String;
      Email    : Unbounded_String;
      Called   : Natural := 0;
      Gender   : Unbounded_String;
   end record;
   type Form_Bean_Access is access all Form_Bean'Class;

   --  Get the value identified by the name.
   overriding
   function Get_Value (From : in Form_Bean;
                       Name : in String) return Util.Beans.Objects.Object;

   --  Set the value identified by the name.
   overriding
   procedure Set_Value (From  : in out Form_Bean;
                        Name  : in String;
                        Value : in Util.Beans.Objects.Object);

   --  This bean provides some methods that can be used in a Method_Expression
   overriding
   function Get_Method_Bindings (From : in Form_Bean)
                                 return Util.Beans.Methods.Method_Binding_Array_Access;

   --  Action to save the form
   procedure Save (Data    : in out Form_Bean;
                   Outcome : in out Unbounded_String);

end ASF.Applications.Tests;