-----------------------------------------------------------------------
--  contexts-facelets -- Contexts for facelets
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

with Ada.Directories;

with Util.Files;
with EL.Variables;
with ASF.Applications.Main;
with ASF.Views.Nodes.Facelets;
package body ASF.Contexts.Facelets is

   --  ------------------------------
   --  Get the EL context for evaluating expressions.
   --  ------------------------------
   function Get_ELContext (Context : in Facelet_Context)
                           return EL.Contexts.ELContext_Access is
   begin
      return Context.Context;
   end Get_ELContext;

   --  ------------------------------
   --  Set the EL context for evaluating expressions.
   --  ------------------------------
   procedure Set_ELContext (Context   : in out Facelet_Context;
                            ELContext : in EL.Contexts.ELContext_Access) is
   begin
      Context.Context := ELContext;
   end Set_ELContext;

   --  ------------------------------
   --  Get the function mapper associated with the EL context.
   --  ------------------------------
   function Get_Function_Mapper (Context : in Facelet_Context)
                                 return EL.Functions.Function_Mapper_Access is
      use EL.Contexts;
   begin
      if Context.Context = null then
         return null;
      else
         return Context.Context.Get_Function_Mapper;
      end if;
   end Get_Function_Mapper;

   --  ------------------------------
   --  Set the attribute having given name with the value.
   --  ------------------------------
   procedure Set_Attribute (Context : in out Facelet_Context;
                            Name    : in String;
                            Value   : in EL.Objects.Object) is
   begin
      null;
   end Set_Attribute;

   --  ------------------------------
   --  Set the attribute having given name with the value.
   --  ------------------------------
   procedure Set_Attribute (Context : in out Facelet_Context;
                            Name    : in Unbounded_String;
                            Value   : in EL.Objects.Object) is
   begin
      null;
   end Set_Attribute;

   --  ------------------------------
   --  Set the attribute having given name with the value expression.
   --  ------------------------------
   procedure Set_Variable (Context : in out Facelet_Context;
                           Name    : in Unbounded_String;
                           Value   : in EL.Expressions.Value_Expression) is
      Mapper : constant access EL.Variables.VariableMapper'Class
        := Context.Context.Get_Variable_Mapper;
   begin
      if Mapper /= null then
         Mapper.Set_Variable (Name, Value);
      end if;
   end Set_Variable;

   --  ------------------------------
   --  Include the facelet from the given source file.
   --  The included views appended to the parent component tree.
   --  ------------------------------
   procedure Include_Facelet (Context : in out Facelet_Context;
                              Source  : in String;
                              Parent  : in Base.UIComponent_Access) is
   begin
      null;
   end Include_Facelet;

   --  ------------------------------
   --  Include the definition having the given name.
   --  ------------------------------
   procedure Include_Definition (Context : in out Facelet_Context;
                                 Name    : in Unbounded_String;
                                 Parent  : in Base.UIComponent_Access;
                                 Found   : out Boolean) is
      Node      : Composition_Tag_Node;
      Iter      : Defines_Vector.Cursor := Context.Defines.Last;
      The_Name  : aliased constant String := To_String (Name);
   begin
      if Context.Inserts.Contains (The_Name'Unchecked_Access) then
         Found := True;
         return;
      end if;
      Context.Inserts.Insert (The_Name'Unchecked_Access);
      while Defines_Vector.Has_Element (Iter) loop
         Node := Defines_Vector.Element (Iter);
         Node.Include_Definition (Parent  => Parent,
                                  Context => Context,
                                  Name    => Name,
                                  Found   => Found);
         if Found then
            Context.Inserts.Delete (The_Name'Unchecked_Access);
            return;
         end if;
         Defines_Vector.Previous (Iter);
      end loop;
      Found := False;
      Context.Inserts.Delete (The_Name'Unchecked_Access);
   end Include_Definition;

   --  ------------------------------
   --  Push into the current facelet context the <ui:define> nodes contained in
   --  the composition/decorate tag.
   --  ------------------------------
   procedure Push_Defines (Context : in out Facelet_Context;
                           Node : access ASF.Views.Nodes.Facelets.Composition_Tag_Node) is
   begin
      Context.Defines.Append (Node.all'Access);
   end Push_Defines;

   --  ------------------------------
   --  Pop from the current facelet context the <ui:define> nodes.
   --  ------------------------------
   procedure Pop_Defines (Context : in out Facelet_Context) is
      use Ada.Containers;
   begin
      if Context.Defines.Length > 0 then
         Context.Defines.Delete_Last;
      end if;
   end Pop_Defines;

   --  ------------------------------
   --  Set the path to resolve relative facelet paths and get the previous path.
   --  ------------------------------
   procedure Set_Relative_Path (Context  : in out Facelet_Context;
                                Path     : in Unbounded_String;
                                Previous : out Unbounded_String) is
      File : constant String := To_String (Path);
   begin
      Previous := Context.Path;
      Context.Path := To_Unbounded_String (Ada.Directories.Containing_Directory (File));
   end Set_Relative_Path;

   --  ------------------------------
   --  Set the path to resolve relative facelet paths.
   --  ------------------------------
   procedure Set_Relative_Path (Context  : in out Facelet_Context;
                                Path     : in Unbounded_String) is
   begin
      Context.Path := Path;
   end Set_Relative_Path;

   --  ------------------------------
   --  Resolve the facelet relative path
   --  ------------------------------
   function Resolve_Path (Context : Facelet_Context;
                          Path    : String) return String is
   begin
      if Path (Path'First) = '/' then
         return Path;
      else
         return Util.Files.Compose (To_String (Context.Path), Path);
      end if;
   end Resolve_Path;

   --  ------------------------------
   --  Get a converter from a name.
   --  Returns the converter object or null if there is no converter.
   --  ------------------------------
   function Get_Converter (Context : in Facelet_Context;
                           Name    : in EL.Objects.Object)
                           return ASF.Converters.Converter_Access is
   begin
      return Facelet_Context'Class (Context).Get_Application.Find (Name);
   end Get_Converter;

   --  ------------------------------
   --  Get a validator from a name.
   --  Returns the validator object or null if there is no validator.
   --  ------------------------------
   function Get_Validator (Context : in Facelet_Context;
                           Name    : in EL.Objects.Object)
                           return ASF.Validators.Validator_Access is
   begin
      return Facelet_Context'Class (Context).Get_Application.Find_Validator (Name);
   end Get_Validator;

end ASF.Contexts.Facelets;