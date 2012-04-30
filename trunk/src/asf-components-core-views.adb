-----------------------------------------------------------------------
--  components-core-views -- ASF View Components
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
with Ada.Unchecked_Deallocation;

with ASF.Events.Phases;
with ASF.Components.Base;

package body ASF.Components.Core.Views is

   use ASF;
   use EL.Objects;

   procedure Free is
     new Ada.Unchecked_Deallocation (Object => ASF.Events.Faces.Faces_Event'Class,
                                     Name   => Faces_Event_Access);

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
      UI.Broadcast (ASF.Events.Phases.APPLY_REQUEST_VALUES, Context);

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
      UI.Broadcast (ASF.Events.Phases.PROCESS_VALIDATION, Context);

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
      UI.Broadcast (ASF.Events.Phases.UPDATE_MODEL_VALUES, Context);

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
      UI.Broadcast (ASF.Events.Phases.INVOKE_APPLICATION, Context);
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

end ASF.Components.Core.Views;