-----------------------------------------------------------------------
--  asf.beans -- Bean Registration and Factory
--  Copyright (C) 2009, 2010, 2011 Stephane Carrez
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

with Util.Log.Loggers;
package body ASF.Beans is

   use Util.Log;

   --  The logger
   Log : constant Loggers.Logger := Loggers.Create ("ASF.Beans");

   --  ------------------------------
   --  Register under the name identified by <b>Name</b> the class instance <b>Class</b>.
   --  ------------------------------
   procedure Register_Class (Factory : in out Bean_Factory;
                             Name    : in String;
                             Class   : in Class_Binding_Access) is
   begin
      Log.Info ("Register bean class {0}", Name);

      Factory.Registry.Include (Name, Class);
   end Register_Class;

   --  ------------------------------
   --  Register the bean identified by <b>Name</b> and associated with the class <b>Class</b>.
   --  The class must have been registered by using the <b>Register</b> class operation.
   --  The scope defines the scope of the bean.
   --  ------------------------------
   procedure Register (Factory : in out Bean_Factory;
                       Name    : in String;
                       Class   : in String;
                       Scope   : in Scope_Type := REQUEST_SCOPE) is
   begin
      Log.Info ("Register bean '{0}' created by '{1}' in scope {2}",
                Name, Class, Scope_Type'Image (Scope));

      declare
         Pos     : constant Registry_Maps.Cursor := Factory.Registry.Find (Class);
         Binding : Bean_Binding;
      begin
         if not Registry_Maps.Has_Element (Pos) then
            Log.Error ("Class '{0}' does not exist.  Cannot register bean '{1}'",
                       Class, Name);
            return;
         end if;
         Binding.Create := Registry_Maps.Element (Pos);
         Binding.Scope  := Scope;
         Factory.Map.Include (Ada.Strings.Unbounded.To_Unbounded_String (Name), Binding);
      end;
   end Register;

   --  ------------------------------
   --  Register the bean identified by <b>Name</b> and associated with the class <b>Class</b>.
   --  The class must have been registered by using the <b>Register</b> class operation.
   --  The scope defines the scope of the bean.
   --  ------------------------------
   procedure Register (Factory : in out Bean_Factory;
                       Name    : in String;
                       Class   : in Class_Binding_Access;
                       Scope   : in Scope_Type := REQUEST_SCOPE) is
      Binding : Bean_Binding;
   begin
      Log.Info ("Register bean '{0}' in scope {2}",
                Name, Scope_Type'Image (Scope));

      Binding.Create := Class;
      Binding.Scope  := Scope;
      Factory.Map.Include (Ada.Strings.Unbounded.To_Unbounded_String (Name), Binding);
   end Register;

   --  ------------------------------
   --  Register all the definitions from a factory to a main factory.
   --  ------------------------------
   procedure Register (Factory : in out Bean_Factory;
                       From    : in Bean_Factory) is
   begin
      declare
         Pos : Registry_Maps.Cursor := From.Registry.First;
      begin
         while Registry_Maps.Has_Element (Pos) loop
            Factory.Registry.Include (Key      => Registry_Maps.Key (Pos),
                                      New_Item => Registry_Maps.Element (Pos));
            Registry_Maps.Next (Pos);
         end loop;
      end;
      declare
         Pos : Bean_Maps.Cursor := Bean_Maps.First (From.Map);
      begin
         while Bean_Maps.Has_Element (Pos) loop
            Factory.Map.Include (Key      => Bean_Maps.Key (Pos),
                                 New_Item => Bean_Maps.Element (Pos));
            Bean_Maps.Next (Pos);
         end loop;
      end;
   end Register;

   --  ------------------------------
   --  Create a bean by using the create operation registered for the name
   --  ------------------------------
   procedure Create (Factory : in Bean_Factory;
                     Name    : in Unbounded_String;
                     Result  : out Util.Beans.Basic.Readonly_Bean_Access;
                     Scope   : out Scope_Type) is
      Pos : constant Bean_Maps.Cursor := Factory.Map.Find (Name);
   begin
      if Bean_Maps.Has_Element (Pos) then
         declare
            Binding : constant Bean_Binding := Bean_Maps.Element (Pos);
         begin
            Binding.Create.Create (Name, Result);
            Scope := Binding.Scope;
         end;
      else
         Result := null;
         Scope := ANY_SCOPE;
      end if;
   end Create;

end ASF.Beans;
