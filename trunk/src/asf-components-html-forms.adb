-----------------------------------------------------------------------
--  html.forms -- ASF HTML Form Components
--  Copyright (C) 2010 Stephane Carrez
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
with Ada.Exceptions;
with ASF.Utils;
with ASF.Components.Utils;
with ASF.Events.Actions;
with ASF.Applications.Main;
package body ASF.Components.Html.Forms is

   use Util.Log;

   --  The logger
   Log : constant Loggers.Logger := Loggers.Create ("ASF.Components.Html.Forms");

   FORM_ATTRIBUTE_NAMES   : Util.Strings.String_Set.Set;

   INPUT_ATTRIBUTE_NAMES  : Util.Strings.String_Set.Set;

   --  ------------------------------
   --  Input Component
   --  ------------------------------

   --  ------------------------------
   --  Create an UIInput secret component
   --  ------------------------------
   function Create_Input_Secret return ASF.Components.Base.UIComponent_Access is
      Result : constant UIInput_Access := new UIInput;
   begin
      Result.Is_Secret := True;
      return Result.all'Access;
   end Create_Input_Secret;

   --  ------------------------------
   --  Check if this component has the required attribute set.
   --  ------------------------------
   function Is_Required (UI      : in UIInput;
                         Context : in Faces_Context'Class) return Boolean is
      Attr : constant EL.Objects.Object := UI.Get_Attribute (Name    => "required",
                                                             Context => Context);
   begin
      if EL.Objects.Is_Null (Attr) then
         return True;
      end if;
      return EL.Objects.To_Boolean (Attr);
   end Is_Required;

   overriding
   procedure Encode_Begin (UI      : in UIInput;
                           Context : in out Faces_Context'Class) is
   begin
      if not UI.Is_Rendered (Context) then
         return;
      end if;
      declare
         Writer : constant ResponseWriter_Access := Context.Get_Response_Writer;
         Value  : constant EL.Objects.Object := UIInput'Class (UI).Get_Value;
      begin
         Writer.Start_Element ("input");
         if UI.Is_Secret then
            Writer.Write_Attribute (Name => "type", Value => "password");
         else
            Writer.Write_Attribute (Name => "type", Value => "text");
         end if;
         Writer.Write_Attribute (Name => "name", Value => UI.Get_Client_Id);
         if not EL.Objects.Is_Null (Value) then
            declare
               Convert : constant access Converters.Converter'Class
                 := UIInput'Class (UI).Get_Converter;
            begin
               if Convert /= null then
                  Writer.Write_Attribute (Name  => "value",
                                          Value => Convert.To_String (Value => Value,
                                                                      Component => UI,
                                                                      Context => Context));
               else
                  Writer.Write_Attribute (Name => "value", Value => Value);
               end if;
            end;
         end if;
         UI.Render_Attributes (Context, INPUT_ATTRIBUTE_NAMES, Writer);
         Writer.End_Element ("input");
      end;
   end Encode_Begin;

   overriding
   procedure Process_Decodes (UI      : in out UIInput;
                              Context : in out Faces_Context'Class) is
   begin
      if not UI.Is_Rendered (Context) then
         return;
      end if;
      declare
         Id  : constant Unbounded_String := UI.Get_Client_Id;
         Val : constant String := Context.Get_Parameter (To_String (Id));
      begin
         if not UI.Is_Secret then
            Log.Info ("Set input parameter {0} -> {1}", Id, Val);
         end if;
         UI.Submitted_Value := UI.Convert_Value (Val, Context);
         UI.Is_Valid := True;

      exception
         when E : others =>
            UI.Is_Valid := False;
            Log.Info (Utils.Get_Line_Info (UI)
                      & ": Exception raised when converting value {0} for component {1}: {2}",
                      Val, To_String (Id), Ada.Exceptions.Exception_Name (E));
      end;
   end Process_Decodes;

   procedure Add_Message (UI : in Base.UIComponent'Class;
                          Name : in String;
                          Default : in String;
                          Context : in out Faces_Context'Class) is
      Id  : constant String := To_String (UI.Get_Client_Id);
      Msg : constant EL.Objects.Object := UI.Get_Attribute (Name => Name, Context => Context);
   begin
      if EL.Objects.Is_Null (Msg) then
         Context.Add_Message (Client_Id => Id, Message => Default);
      else
         Context.Add_Message (Client_Id => Id, Message => EL.Objects.To_String (Msg));
      end if;
   end Add_Message;

   --  ------------------------------
   --  Validate the submitted value.
   --  <ul>
   --     <li>Retreive the submitted value
   --     <li>If the value is null, exit without further processing.
   --     <li>Validate the value by calling <b>Validate_Value</b>
   --  </ul>
   --  ------------------------------
   procedure Validate (UI      : in out UIInput;
                       Context : in out Faces_Context'Class) is
   begin
      if not EL.Objects.Is_Null(UI.Submitted_Value) then
         UIInput'Class (UI).Validate_Value (UI.Submitted_Value, Context);

         --  Render the response after the current phase if something is wrong.
         if not UI.Is_Valid then
            Context.Render_Response;
         end if;
      end if;
   end Validate;

   --  ------------------------------
   --  Set the <b>valid</b> property:
   --  <ul>
   --     <li>If the <b>required</b> property is true, ensure the
   --         value is not empty
   --     <li>Call the <b>Validate</b> procedure on each validator
   --         registered on this component.
   --     <li>Set the <b>valid</b> property if all validator passed.
   --  </ul>
   --  ------------------------------
   procedure Validate_Value (UI      : in out UIInput;
                             Value   : in EL.Objects.Object;
                             Context : in out Faces_Context'Class) is
   begin
      if EL.Objects.Is_Empty (Value) and UI.Is_Required (Context) and UI.Is_Valid then
         Add_Message (UI, "requiredMessage", "req", Context);
         UI.Is_Valid := False;
      end if;

      if UI.Is_Valid and not EL.Objects.Is_Empty (Value) then
         null;
      end if;
   end Validate_Value;

   overriding
   procedure Process_Updates (UI      : in out UIInput;
                              Context : in out Faces_Context'Class) is
      VE    : constant EL.Expressions.Value_Expression := UI.Get_Value_Expression ("value");
   begin
      if UI.Is_Valid then
         VE.Set_Value (Value => UI.Submitted_Value, Context => Context.Get_ELContext.all);
      end if;

   exception
      when E : others =>
         UI.Is_Valid := False;
         Log.Info (Utils.Get_Line_Info (UI)
                   & ": Exception raised when updating value {0} for component {1}: {2}",
                   EL.Objects.To_String (UI.Submitted_Value),
                   To_String (UI.Get_Client_Id), Ada.Exceptions.Exception_Name (E));
   end Process_Updates;

   --  ------------------------------
   --  Button Component
   --  ------------------------------

   --  ------------------------------
   --  Get the value to write on the output.
   --  ------------------------------
   function Get_Value (UI    : in UICommand) return EL.Objects.Object is
   begin
      return UI.Get_Attribute (UI.Get_Context.all, "value");
   end Get_Value;

   --  ------------------------------
   --  Set the value to write on the output.
   --  ------------------------------
   procedure Set_Value (UI    : in out UICommand;
                        Value : in EL.Objects.Object) is
   begin
      UI.Value := Value;
   end Set_Value;

   --  ------------------------------
   --  Get the action method expression to invoke if the command is pressed.
   --  ------------------------------
   function Get_Action_Expression (UI      : in UICommand;
                                   Context : in Faces_Context'Class)
                                   return EL.Expressions.Method_Expression is
      pragma Unreferenced (Context);
   begin
      return UI.Get_Method_Expression (Name => "action");
   end Get_Action_Expression;

   overriding
   procedure Process_Decodes (UI      : in out UICommand;
                              Context : in out Faces_Context'Class) is
   begin
      if not UI.Is_Rendered (Context) then
         return;
      end if;
      declare
         Id  : constant Unbounded_String := UI.Get_Client_Id;
         Val : constant String := Context.Get_Parameter (To_String (Id));
      begin
         Log.Info ("Check command input parameter {0} -> {1}", Id, Val);
         if Val /= "" then
            ASF.Events.Actions.Post_Event (UI     => UI,
                                           Method => UI.Get_Action_Expression (Context));
         end if;

      exception
         when EL.Expressions.Invalid_Expression =>
            null;
      end;
   end Process_Decodes;

   --  ------------------------------
   --  Broadcast the event to the event listeners installed on this component.
   --  Listeners are called in the order in which they were added.
   --  ------------------------------
   overriding
   procedure Broadcast (UI      : in out UICommand;
                        Event   : not null access ASF.Events.Faces_Event'Class;
                        Context : in out Faces_Context'Class) is
      pragma Unreferenced (UI);

      use ASF.Events.Actions;

      App  : constant access Applications.Main.Application'Class := Context.Get_Application;
      Disp : constant Action_Listener_Access := App.Get_Action_Listener;
   begin
      if Disp /= null and Event.all in Action_Event'Class then
         Disp.Process_Action (Event   => Action_Event (Event.all),
                              Context => Context);
      end if;
   end Broadcast;

   overriding
   procedure Encode_Begin (UI      : in UICommand;
                           Context : in out Faces_Context'Class) is
   begin
      if not UI.Is_Rendered (Context) then
         return;
      end if;
      declare
         Writer : constant ResponseWriter_Access := Context.Get_Response_Writer;
         Value  : constant EL.Objects.Object := UI.Get_Value;
      begin
         Writer.Start_Element ("input");
         Writer.Write_Attribute (Name => "type", Value => "submit");
         Writer.Write_Attribute (Name => "name", Value => UI.Get_Client_Id);
         if not EL.Objects.Is_Null (Value) then
            Writer.Write_Attribute (Name => "value", Value => Value);
         end if;
         UI.Render_Attributes (Context, INPUT_ATTRIBUTE_NAMES, Writer);
         Writer.End_Element ("input");
      end;
   end Encode_Begin;

   --  ------------------------------
   --  Form Component
   --  ------------------------------

   --  ------------------------------
   --  Check whether the form is submitted.
   --  ------------------------------
   function Is_Submitted (UI : in UIForm) return Boolean is
   begin
      return UI.Is_Submitted;
   end Is_Submitted;

   --  ------------------------------
   --  Called during the <b>Apply Request</b> phase to indicate that this
   --  form is submitted.
   --  ------------------------------
   procedure Set_Submitted (UI : in out UIForm) is
   begin
      UI.Is_Submitted := True;
   end Set_Submitted;

   --  Get the action URL to set on the HTML form
   function Get_Action (UI      : in UIForm;
                        Context : in Faces_Context'Class) return String is
      pragma Unreferenced (UI, Context);
   begin
      return "";
   end Get_Action;

   overriding
   procedure Encode_Begin (UI      : in UIForm;
                           Context : in out Faces_Context'Class) is
   begin
      if not UI.Is_Rendered (Context) then
         return;
      end if;
      declare
         Writer : constant ResponseWriter_Access := Context.Get_Response_Writer;
         Id     : constant Unbounded_String := UI.Get_Client_Id;
      begin
         Writer.Start_Element ("form");
         Writer.Write_Attribute (Name => "method", Value => "post");
         Writer.Write_Attribute (Name => "name", Value => Id);
         Writer.Write_Attribute (Name => "action", Value => UI.Get_Action (Context));
         UI.Render_Attributes (Context, FORM_ATTRIBUTE_NAMES, Writer);

         Writer.Start_Element ("input");
         Writer.Write_Attribute (Name => "type", Value => "hidden");
         Writer.Write_Attribute (Name => "name", Value => Id);
         Writer.Write_Attribute (Name => "value", Value => "1");
         Writer.End_Element ("input");
      end;
   end Encode_Begin;

   overriding
   procedure Encode_End (UI      : in UIForm;
                         Context : in out Faces_Context'Class) is
   begin
      if not UI.Is_Rendered (Context) then
         return;
      end if;
      declare
         Writer : constant ResponseWriter_Access := Context.Get_Response_Writer;
      begin
         Writer.End_Element ("form");
      end;
   end Encode_End;

   overriding
   procedure Decode (UI      : in out UIForm;
                     Context : in out Faces_Context'Class) is
      Id  : constant Unbounded_String := UI.Get_Client_Id;
      Val : constant String := Context.Get_Parameter (To_String (Id));
   begin
      if Val /= "" then
         UIForm'Class (UI).Set_Submitted;
      end if;
   end Decode;

   overriding
   procedure Process_Decodes (UI      : in out UIForm;
                              Context : in out Faces_Context'Class) is
   begin
      --  Do not decode the component nor its children if the component is not rendered.
      if not UI.Is_Rendered (Context) then
         return;
      end if;

      Base.UIComponent'Class (UI).Decode (Context);

      --  If the form is submitted, process the children.
      --  Otherwise, none of the parameters are for this form.
      if UI.Is_Submitted then
         Log.Info ("Decoding form {0}", UI.Get_Client_Id);

         UI.Decode_Children (Context);
      end if;
   end Process_Decodes;

begin
   ASF.Utils.Set_Text_Attributes (FORM_ATTRIBUTE_NAMES);
   ASF.Utils.Set_Text_Attributes (INPUT_ATTRIBUTE_NAMES);
   ASF.Utils.Set_Interactive_Attributes (INPUT_ATTRIBUTE_NAMES);
   ASF.Utils.Set_Interactive_Attributes (FORM_ATTRIBUTE_NAMES);
   ASF.Utils.Set_Input_Attributes (INPUT_ATTRIBUTE_NAMES);
end ASF.Components.Html.Forms;
