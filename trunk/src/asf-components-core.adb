-----------------------------------------------------------------------
--  components-core -- ASF Core Components
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

with Util.Beans.Objects;
with Ada.Unchecked_Deallocation;
package body ASF.Components.Core is

   use ASF;
   use EL.Objects;

   procedure Free is
     new Ada.Unchecked_Deallocation (Object => ASF.Events.Faces.Faces_Event'Class,
                                     Name   => Faces_Event_Access);

   --  ------------------------------
   --  Return a client-side identifier for this component, generating
   --  one if necessary.
   --  ------------------------------
   function Get_Client_Id (UI : UIComponentBase) return Unbounded_String is
      Id : constant access ASF.Views.Nodes.Tag_Attribute := UI.Get_Attribute ("id");
   begin
      if Id /= null then
         return To_Unbounded_String (Views.Nodes.Get_Value (Id.all, UI.Get_Context.all));
      end if;
      --        return UI.Id;
      return Base.UIComponent (UI).Get_Client_Id;
   end Get_Client_Id;

   --  ------------------------------
   --  Renders the UIText evaluating the EL expressions it may contain.
   --  ------------------------------
   procedure Encode_Begin (UI      : in UIText;
                           Context : in out Faces_Context'Class) is
   begin
      UI.Text.Encode_All (UI.Expr_Table, Context);
   end Encode_Begin;

   --  ------------------------------
   --  Set the expression array that contains reduced expressions.
   --  ------------------------------
   procedure Set_Expression_Table (UI         : in out UIText;
                                   Expr_Table : in Views.Nodes.Expression_Access_Array_Access) is
      use type ASF.Views.Nodes.Expression_Access_Array_Access;
   begin
      if UI.Expr_Table /= null then
         raise Program_Error with "Expression table already initialized";
      end if;
      UI.Expr_Table := Expr_Table;
   end Set_Expression_Table;

   --  ------------------------------
   --  Finalize the object.
   --  ------------------------------
   overriding
   procedure Finalize (UI : in out UIText) is
      use type ASF.Views.Nodes.Expression_Access_Array_Access;

      procedure Free is
        new Ada.Unchecked_Deallocation (EL.Expressions.Expression'Class,
                                        EL.Expressions.Expression_Access);
      procedure Free is
        new Ada.Unchecked_Deallocation (ASF.Views.Nodes.Expression_Access_Array,
                                        ASF.Views.Nodes.Expression_Access_Array_Access);
   begin
      if UI.Expr_Table /= null then
         for I in UI.Expr_Table'Range loop
            Free (UI.Expr_Table (I));
         end loop;
         Free (UI.Expr_Table);
      end if;
   end Finalize;

   function Create_UIText (Tag : ASF.Views.Nodes.Text_Tag_Node_Access)
                           return UIText_Access is
      Result : constant UIText_Access := new UIText;
   begin
      Result.Text := Tag;
      return Result;
   end Create_UIText;

   --  ------------------------------
   --  Get the content type returned by the view.
   --  ------------------------------
   function Get_Content_Type (UI      : in UIView;
                              Context : in Faces_Context'Class) return String is
   begin
      if Util.Beans.Objects.Is_Null (UI.Content_Type) then
         return UI.Get_Attribute (Name => "contentType", Context => Context);
      else
         return Util.Beans.Objects.To_String (UI.Content_Type);
      end if;
   end Get_Content_Type;

   --  ------------------------------
   --  Set the content type returned by the view.
   --  ------------------------------
   procedure Set_Content_Type (UI     : in out UIView;
                               Value  : in String) is
   begin
      UI.Content_Type := Util.Beans.Objects.To_Object (Value);
   end Set_Content_Type;

   --  ------------------------------
   --  Encode the begining of the view.  Set the response content type.
   --  ------------------------------
   overriding
   procedure Encode_Begin (UI      : in UIView;
                           Context : in out Faces_Context'Class) is
      Content_Type : constant String := UI.Get_Content_Type (Context => Context);
   begin
      Context.Get_Response.Set_Content_Type (Content_Type);
   end Encode_Begin;

   --  ------------------------------
   --  Decode any new state of the specified component from the request contained
   --  in the specified context and store that state on the component.
   --
   --  During decoding, events may be enqueued for later processing
   --  (by event listeners that have registered an interest), by calling
   --  the <b>Queue_Event</b> on the associated component.
   --  ------------------------------
   overriding
   procedure Process_Decodes (UI      : in out UIView;
                              Context : in out Faces_Context'Class) is
   begin
      Base.UIComponent (UI).Process_Decodes (Context);

      --  Dispatch events queued for this phase.
      UI.Broadcast (ASF.Lifecycles.APPLY_REQUEST_VALUES, Context);

      --  Drop other events if the response is to be returned.
      if Context.Get_Render_Response or Context.Get_Response_Completed then
         UI.Clear_Events;
      end if;
   end Process_Decodes;

   --  ------------------------------
   --  Perform the component tree processing required by the <b>Process Validations</b>
   --  phase of the request processing lifecycle for all facets of this component,
   --  all children of this component, and this component itself, as follows:
   --  <ul>
   --    <li>If this component <b>rendered</b> property is false, skip further processing.
   --    <li>Call the <b>Process_Validators</b> of all facets and children.
   --  <ul>
   --  ------------------------------
   overriding
   procedure Process_Validators (UI      : in out UIView;
                                 Context : in out Faces_Context'Class) is
   begin
      Base.UIComponent (UI).Process_Validators (Context);

      --  Dispatch events queued for this phase.
      UI.Broadcast (ASF.Lifecycles.PROCESS_VALIDATION, Context);

      --  Drop other events if the response is to be returned.
      if Context.Get_Render_Response or Context.Get_Response_Completed then
         UI.Clear_Events;
      end if;
   end Process_Validators;

   --  ------------------------------
   --  Perform the component tree processing required by the <b>Update Model Values</b>
   --  phase of the request processing lifecycle for all facets of this component,
   --  all children of this component, and this component itself, as follows.
   --  <ul>
   --    <li>If this component <b>rendered</b> property is false, skip further processing.
   --    <li>Call the <b>Process_Updates/b> of all facets and children.
   --  <ul>
   --  ------------------------------
   overriding
   procedure Process_Updates (UI      : in out UIView;
                              Context : in out Faces_Context'Class) is
   begin
      Base.UIComponent (UI).Process_Updates (Context);

      --  Dispatch events queued for this phase.
      UI.Broadcast (ASF.Lifecycles.UPDATE_MODEL_VALUES, Context);

      --  Drop other events if the response is to be returned.
      if Context.Get_Render_Response or Context.Get_Response_Completed then
         UI.Clear_Events;
      end if;
   end Process_Updates;

   --  ------------------------------
   --  Broadcast any events that have been queued for the <b>Invoke Application</b>
   --  phase of the request processing lifecycle and to clear out any events
   --  for later phases if the event processing for this phase caused
   --  <b>renderResponse</b> or <b>responseComplete</b> to be called.
   --  ------------------------------
   procedure Process_Application (UI      : in out UIView;
                                  Context : in out Faces_Context'Class) is
   begin
      --  Dispatch events queued for this phase.
      UI.Broadcast (ASF.Lifecycles.INVOKE_APPLICATION, Context);
   end Process_Application;

   --  ------------------------------
   --  Queue an event for broadcast at the end of the current request
   --  processing lifecycle phase.  The event object
   --  will be freed after being dispatched.
   --  ------------------------------
   procedure Queue_Event (UI    : in out UIView;
                          Event : not null access ASF.Events.Faces.Faces_Event'Class) is
      use type Base.UIComponent_Access;

      Parent : constant Base.UIComponent_Access := UI.Get_Parent;
   begin
      if Parent /= null then
         Parent.Queue_Event (Event);
      else
         UI.Phase_Events (Event.Get_Phase).Append (Event.all'Access);
      end if;
   end Queue_Event;

   --  ------------------------------
   --  Broadcast the events after the specified lifecycle phase.
   --  Events that were queued will be freed.
   --  ------------------------------
   procedure Broadcast (UI      : in out UIView;
                        Phase   : in ASF.Lifecycles.Phase_Type;
                        Context : in out Faces_Context'Class) is

      Pos : Natural := 0;

      --  Broadcast the event to the component's listeners
      --  and free that event.
      procedure Broadcast (Ev : in out Faces_Event_Access);

      procedure Broadcast (Ev : in out Faces_Event_Access) is
      begin
         if Ev /= null then
            declare
               C  : constant Base.UIComponent_Access := Ev.Get_Component;
            begin
               C.Broadcast (Ev, Context);
            end;
            Free (Ev);
         end if;
      end Broadcast;

   begin
      --  Dispatch events in the order in which they were queued.
      --  More events could be queued as a result of the dispatch.
      --  After dispatching an event, it is freed but not removed
      --  from the event queue (the access will be cleared).
      loop
         exit when Pos > UI.Phase_Events (Phase).Last_Index;
         UI.Phase_Events (Phase).Update_Element (Pos, Broadcast'Access);
         Pos := Pos + 1;
      end loop;

      --  Now, clear the queue.
      UI.Phase_Events (Phase).Clear;
   end Broadcast;

   --  ------------------------------
   --  Clear the events that were queued.
   --  ------------------------------
   procedure Clear_Events (UI : in out UIView) is
   begin
      for Phase in UI.Phase_Events'Range loop
         for I in 0 .. UI.Phase_Events (Phase).Last_Index loop
            declare
               Ev : Faces_Event_Access := UI.Phase_Events (Phase).Element (I);
            begin
               Free (Ev);
            end;
         end loop;
         UI.Phase_Events (Phase).Clear;
      end loop;
   end Clear_Events;

   --  ------------------------------
   --  Abstract Leaf component
   --  ------------------------------
   overriding
   procedure Encode_Children (UI      : in UILeaf;
                              Context : in out Faces_Context'Class) is
   begin
      null;
   end Encode_Children;

   overriding
   procedure Encode_Begin (UI      : in UILeaf;
                           Context : in out Faces_Context'Class) is
   begin
      null;
   end Encode_Begin;

   overriding
   procedure Encode_End (UI      : in UILeaf;
                         Context : in out Faces_Context'Class) is
   begin
      null;
   end Encode_End;

   --  ------------------------------
   --  Component Parameter
   --  ------------------------------

   --  ------------------------------
   --  Get the parameter name
   --  ------------------------------
   function Get_Name (UI      : UIParameter;
                      Context : Faces_Context'Class) return String is
      Name : constant EL.Objects.Object := UI.Get_Attribute (Name    => "name",
                                                             Context => Context);
   begin
      return EL.Objects.To_String (Name);
   end Get_Name;

   --  ------------------------------
   --  Get the parameter value
   --  ------------------------------
   function Get_Value (UI      : UIParameter;
                       Context : Faces_Context'Class) return EL.Objects.Object is
   begin
      return UI.Get_Attribute (Name => "value", Context => Context);
   end Get_Value;

   --  ------------------------------
   --  Get the list of parameters associated with a component.
   --  ------------------------------
   function Get_Parameters (UI : Base.UIComponent'Class) return UIParameter_Access_Array is

      Result : UIParameter_Access_Array (1 .. UI.Get_Children_Count);
      Last   : Natural := 0;

      procedure Collect (Child : in Base.UIComponent_Access);
      pragma Inline (Collect);

      procedure Collect (Child : in Base.UIComponent_Access) is
      begin
         if Child.all in UIParameter'Class then
            Last := Last + 1;
            Result (Last) :=  UIParameter (Child.all)'Access;
         end if;
      end Collect;

      procedure Iter is new ASF.Components.Base.Iterate (Process => Collect);
      pragma Inline (Iter);

   begin
      Iter (UI);
      return Result (1 .. Last);
   end Get_Parameters;

end ASF.Components.Core;
