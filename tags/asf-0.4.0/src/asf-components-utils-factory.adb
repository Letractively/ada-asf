-----------------------------------------------------------------------
--  core-factory -- Factory for Core UI Components
--  Copyright (C) 2009, 2010, 2011, 2012 Stephane Carrez
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

with ASF.Views.Nodes;
with ASF.Components.Utils.Files;
with ASF.Components.Utils.Flush;
with ASF.Components.Utils.Scripts;
with ASF.Components.Utils.Escapes;
with ASF.Components.Utils.Beans;
with ASF.Components.Html.Messages;
with Util.Strings.Transforms; use Util.Strings;
package body ASF.Components.Utils.Factory is

   use ASF.Components.Base;

   function Create_File return UIComponent_Access;
   function Create_Flush return UIComponent_Access;
   function Create_Script return UIComponent_Access;
   function Create_Escape return UIComponent_Access;
   function Create_Set return UIComponent_Access;

   --  -------------------------
   --  ------------------------------
   --  Create a UIFile component
   --  ------------------------------
   function Create_File return UIComponent_Access is
   begin
      return new ASF.Components.Utils.Files.UIFile;
   end Create_File;

   --  ------------------------------
   --  Create a UIFlush component
   --  ------------------------------
   function Create_Flush return UIComponent_Access is
   begin
      return new ASF.Components.Utils.Flush.UIFlush;
   end Create_Flush;

   --  ------------------------------
   --  Create a UIScript component
   --  ------------------------------
   function Create_Script return UIComponent_Access is
   begin
      return new ASF.Components.Utils.Scripts.UIScript;
   end Create_Script;

   --  ------------------------------
   --  Create a UIEscape component
   --  ------------------------------
   function Create_Escape return UIComponent_Access is
   begin
      return new ASF.Components.Utils.Escapes.UIEscape;
   end Create_Escape;

   --  ------------------------------
   --  Create a UISetBean component
   --  ------------------------------
   function Create_Set return UIComponent_Access is
   begin
      return new ASF.Components.Utils.Beans.UISetBean;
   end Create_Set;

   use ASF.Views.Nodes;

   URI        : aliased constant String := "http://code.google.com/p/ada-asf/util";
   ESCAPE_TAG : aliased constant String := "escape";
   FILE_TAG   : aliased constant String := "file";
   FLUSH_TAG  : aliased constant String := "flush";
   SCRIPT_TAG : aliased constant String := "script";
   SET_TAG    : aliased constant String := "set";

   Core_Bindings : aliased constant ASF.Factory.Binding_Array
     := (1 => (Name      => ESCAPE_TAG'Access,
               Component => Create_Escape'Access,
               Tag       => Create_Component_Node'Access),
         2 => (Name      => FILE_TAG'Access,
               Component => Create_File'Access,
               Tag       => Create_Component_Node'Access),
         3 => (Name      => FLUSH_TAG'Access,
               Component => Create_Flush'Access,
               Tag       => Create_Component_Node'Access),
         4 => (Name      => SCRIPT_TAG'Access,
               Component => Create_Script'Access,
               Tag       => Create_Component_Node'Access),
         5 => (Name      => SET_TAG'Access,
               Component => Create_Set'Access,
               Tag       => Create_Component_Node'Access)
        );

   Core_Factory : aliased constant ASF.Factory.Factory_Bindings
     := (URI => URI'Access, Bindings => Core_Bindings'Access);

   --  ------------------------------
   --  Get the HTML component factory.
   --  ------------------------------
   function Definition return ASF.Factory.Factory_Bindings_Access is
   begin
      return Core_Factory'Access;
   end Definition;

   --  Truncate the string representation represented by <b>Value</b> to
   --  the length specified by <b>Size</b>.
   function Escape_Javascript (Value : EL.Objects.Object) return EL.Objects.Object;

   --  Escape the string using XML escape rules.
   function Escape_Xml (Value : EL.Objects.Object) return EL.Objects.Object;

   procedure Set_Functions (Mapper : in out EL.Functions.Function_Mapper'Class) is
   begin
      Mapper.Set_Function (Name      => "escapeJavaScript",
                           Namespace => URI,
                           Func      => Escape_Javascript'Access);
      Mapper.Set_Function (Name      => "escapeXml",
                           Namespace => URI,
                           Func      => Escape_Xml'Access);
      Mapper.Set_Function (Name      => "hasMessage",
                           Namespace => URI,
                           Func      => ASF.Components.Html.Messages.Has_Message'Access,
                           Optimize  => False);
   end Set_Functions;

   function Escape_Javascript (Value : EL.Objects.Object) return EL.Objects.Object is
      Result  : Ada.Strings.Unbounded.Unbounded_String;
      Content : constant String := EL.Objects.To_String (Value);
   begin
      Transforms.Escape_Javascript (Content => Content,
                                    Into    => Result);
      return EL.Objects.To_Object (Result);
   end Escape_Javascript;

   function Escape_Xml (Value : EL.Objects.Object) return EL.Objects.Object is
      Result  : Ada.Strings.Unbounded.Unbounded_String;
      Content : constant String := EL.Objects.To_String (Value);
   begin
      Transforms.Escape_Xml (Content => Content,
                             Into    => Result);
      return EL.Objects.To_Object (Result);
   end Escape_Xml;

end ASF.Components.Utils.Factory;