-----------------------------------------------------------------------
--  core-factory -- Factory for Core UI Components
--  Copyright (C) 2009, 2010 Stephane Carrez
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

with ASF.Components.Core;
with ASF.Views.Nodes;
with Util.Strings.Transforms; use Util.Strings;
with EL.Functions.Default;
package body ASF.Components.Util.Factory is

   function Create_View return UIComponent_Access;
   function Create_Parameter return UIComponent_Access;

   --  ------------------------------
   --  Create an UIView component
   --  ------------------------------
   function Create_View return UIComponent_Access is
   begin
      return new ASF.Components.Core.UIView;
   end Create_View;

   --  ------------------------------
   --  Create an UIParameter component
   --  ------------------------------
   function Create_Parameter return UIComponent_Access is
   begin
      return new ASF.Components.Core.UIParameter;
   end Create_Parameter;

   use ASF.Views.Nodes;

   URI        : aliased constant String := "http://code.google.com/p/ada-asf/util";
   VIEW_TAG   : aliased constant String := "view";
   PARAM_TAG  : aliased constant String := "param";
   LIST_TAG   : aliased constant String := "list";

   Core_Bindings : aliased constant ASF.Factory.Binding_Array
     := (1 => (Name      => PARAM_TAG'Access,
               Component => Create_Parameter'Access,
               Tag       => Create_Component_Node'Access),
         2 => (Name      => VIEW_TAG'Access,
               Component => Create_View'Access,
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

begin
   ASF.Factory.Check (Core_Factory);
end ASF.Components.Util.Factory;
