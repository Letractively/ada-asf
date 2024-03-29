-----------------------------------------------------------------------
--  widgets-factory -- Factory for widget Components
--  Copyright (C) 2013 Stephane Carrez
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
with ASF.Components.Base;
with ASF.Components.Widgets.Inputs;
with ASF.Components.Widgets.Gravatars;
with ASF.Components.Widgets.Likes;
with ASF.Components.Widgets.Panels;
with ASF.Components.Widgets.Tabs;

package body ASF.Components.Widgets.Factory is

   use ASF.Components.Base;

   function Create_Accordion return UIComponent_Access;
   function Create_Input return UIComponent_Access;
   function Create_Input_Date return UIComponent_Access;
   function Create_Complete return UIComponent_Access;
   function Create_Gravatar return UIComponent_Access;
   function Create_Like return UIComponent_Access;
   function Create_Panel return UIComponent_Access;
   function Create_TabView return UIComponent_Access;
   function Create_Tab return UIComponent_Access;

   --  ------------------------------
   --  Create a UIAccordion component
   --  ------------------------------
   function Create_Accordion return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Tabs.UIAccordion;
   end Create_Accordion;

   --  ------------------------------
   --  Create a UIInput component
   --  ------------------------------
   function Create_Input return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Inputs.UIInput;
   end Create_Input;

   --  ------------------------------
   --  Create a UIInput component
   --  ------------------------------
   function Create_Input_Date return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Inputs.UIInputDate;
   end Create_Input_Date;

   --  ------------------------------
   --  Create a UIComplete component
   --  ------------------------------
   function Create_Complete return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Inputs.UIComplete;
   end Create_Complete;

   --  ------------------------------
   --  Create a UIGravatar component
   --  ------------------------------
   function Create_Gravatar return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Gravatars.UIGravatar;
   end Create_Gravatar;

   --  ------------------------------
   --  Create a UILike component
   --  ------------------------------
   function Create_Like return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Likes.UILike;
   end Create_Like;

   --  ------------------------------
   --  Create a UIPanel component
   --  ------------------------------
   function Create_Panel return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Panels.UIPanel;
   end Create_Panel;

   --  ------------------------------
   --  Create a UITab component
   --  ------------------------------
   function Create_Tab return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Tabs.UITab;
   end Create_Tab;

   --  ------------------------------
   --  Create a UITabView component
   --  ------------------------------
   function Create_TabView return UIComponent_Access is
   begin
      return new ASF.Components.Widgets.Tabs.UITabView;
   end Create_TabView;

   use ASF.Views.Nodes;

   URI              : aliased constant String := "http://code.google.com/p/ada-asf/widget";
   ACCORDION_TAG    : aliased constant String := "accordion";
   AUTOCOMPLETE_TAG : aliased constant String := "autocomplete";
   INPUT_DATE_TAG   : aliased constant String := "inputDate";
   INPUT_TEXT_TAG   : aliased constant String := "inputText";
   GRAVATAR_TAG     : aliased constant String := "gravatar";
   LIKE_TAG         : aliased constant String := "like";
   PANEL_TAG        : aliased constant String := "panel";
   TAB_TAG          : aliased constant String := "tab";
   TAB_VIEW_TAG     : aliased constant String := "tabView";

   Widget_Bindings : aliased constant ASF.Factory.Binding_Array
     := (1 => (Name      => ACCORDION_TAG'Access,
               Component => Create_Accordion'Access,
               Tag       => Create_Component_Node'Access),
         2 => (Name      => AUTOCOMPLETE_TAG'Access,
               Component => Create_Complete'Access,
               Tag       => Create_Component_Node'Access),
         3 => (Name      => INPUT_DATE_TAG'Access,
               Component => Create_Input_Date'Access,
               Tag       => Create_Component_Node'Access),
         4 => (Name      => INPUT_TEXT_TAG'Access,
               Component => Create_Input'Access,
               Tag       => Create_Component_Node'Access),
         5 => (Name      => GRAVATAR_TAG'Access,
               Component => Create_Gravatar'Access,
               Tag       => Create_Component_Node'Access),
         6 => (Name      => LIKE_TAG'Access,
               Component => Create_Like'Access,
               Tag       => Create_Component_Node'Access),
         7 => (Name      => PANEL_TAG'Access,
               Component => Create_Panel'Access,
               Tag       => Create_Component_Node'Access),
         8 => (Name      => TAB_TAG'Access,
               Component => Create_Tab'Access,
               Tag       => Create_Component_Node'Access),
         9 => (Name      => TAB_VIEW_TAG'Access,
               Component => Create_TabView'Access,
               Tag       => Create_Component_Node'Access)
        );

   Core_Factory : aliased constant ASF.Factory.Factory_Bindings
     := (URI => URI'Access, Bindings => Widget_Bindings'Access);

   --  ------------------------------
   --  Get the widget component factory.
   --  ------------------------------
   function Definition return ASF.Factory.Factory_Bindings_Access is
   begin
      return Core_Factory'Access;
   end Definition;

end ASF.Components.Widgets.Factory;
