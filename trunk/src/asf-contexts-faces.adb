-----------------------------------------------------------------------
--  asf-contexts.faces -- Faces Contexts
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

with EL.Variables;
with Ada.Task_Attributes;
with Ada.Unchecked_Deallocation;

with ASF.Converters;
with ASF.Contexts.Exceptions.Iterate;
with ASF.Applications.Main;
package body ASF.Contexts.Faces is

   package Task_Context is new Ada.Task_Attributes
     (Faces_Context_Access, null);

   --  ------------------------------
   --  Get the response writer to write the response stream.
   --  ------------------------------
   function Get_Response_Writer (Context : Faces_Context)
                                 return ASF.Contexts.Writer.Response_Writer_Access is
   begin
      return Context.Writer;
   end Get_Response_Writer;

   --  ------------------------------
   --  Set the response writer to write to the response stream.
   --  ------------------------------
   procedure Set_Response_Writer (Context : in out Faces_Context;
                                  Writer  : in ASF.Contexts.Writer.Response_Writer_Access) is
   begin
      Context.Writer := Writer;
   end Set_Response_Writer;

   --  ------------------------------
   --  Get the EL context for evaluating expressions.
   --  ------------------------------
   function Get_ELContext (Context : in Faces_Context)
                           return EL.Contexts.ELContext_Access is
   begin
      return Context.Context;
   end Get_ELContext;

   --  ------------------------------
   --  Set the EL context for evaluating expressions.
   --  ------------------------------
   procedure Set_ELContext (Context   : in out Faces_Context;
                            ELContext : in EL.Contexts.ELContext_Access) is
   begin
      Context.Context := ELContext;
   end Set_ELContext;

   --  ------------------------------
   --  Set the attribute having given name with the value.
   --  ------------------------------
   procedure Set_Attribute (Context : in out Faces_Context;
                            Name    : in String;
                            Value   : in EL.Objects.Object) is
      use EL.Variables;
      Mapper : constant access Variable_Mapper'Class := Context.Context.Get_Variable_Mapper;
   begin
      Mapper.Bind (Name, Value);
   end Set_Attribute;

   --  ------------------------------
   --  Set the attribute having given name with the value.
   --  ------------------------------
   procedure Set_Attribute (Context : in out Faces_Context;
                            Name    : in Unbounded_String;
                            Value   : in EL.Objects.Object) is
   begin
      Context.Set_Attribute (To_String (Name), Value);
   end Set_Attribute;

   --  ------------------------------
   --  Get a request parameter
   --  ------------------------------
   function Get_Parameter (Context : Faces_Context;
                           Name    : String) return String is
   begin
      return Context.Request.Get_Parameter (Name);
   end Get_Parameter;

   --  ------------------------------
   --  Get the session associated with the current faces context.
   --  ------------------------------
   function Get_Session (Context : in Faces_Context;
                         Create  : in Boolean := False) return ASF.Sessions.Session is
   begin
      return Context.Request.Get_Session (Create);
   end Get_Session;

   --  ------------------------------
   --  Get the request
   --  ------------------------------
   function Get_Request (Context : Faces_Context)
                         return ASF.Requests.Request_Access is
   begin
      return Context.Request;
   end Get_Request;

   --  ------------------------------
   --  Set the request
   --  ------------------------------
   procedure Set_Request (Context : in out Faces_Context;
                          Request : in ASF.Requests.Request_Access) is
   begin
      Context.Request := Request;
   end Set_Request;

   --  ------------------------------
   --  Get the response
   --  ------------------------------
   function Get_Response (Context : Faces_Context) return ASF.Responses.Response_Access is
   begin
      return Context.Response;
   end Get_Response;

   --  ------------------------------
   --  Set the response
   --  ------------------------------
   procedure Set_Response (Context  : in out Faces_Context;
                           Response : in ASF.Responses.Response_Access) is
   begin
      Context.Response := Response;
   end Set_Response;

   --  ------------------------------
   --  Signal the JavaServer faces implementation that, as soon as the
   --  current phase of the request processing lifecycle has been completed,
   --  control should be passed to the <b>Render Response</b> phase,
   --  bypassing any phases that have not been executed yet.
   --  ------------------------------
   procedure Render_Response (Context : in out Faces_Context) is
   begin
      Context.Render_Response := True;
   end Render_Response;

   --  ------------------------------
   --  Check whether the <b>Render_Response</b> phase must be processed immediately.
   --  ------------------------------
   function Get_Render_Response (Context : in Faces_Context) return Boolean is
   begin
      return Context.Render_Response;
   end Get_Render_Response;

   --  ------------------------------
   --  Signal the JavaServer Faces implementation that the HTTP response
   --  for this request has already been generated (such as an HTTP redirect),
   --  and that the request processing lifecycle should be terminated as soon
   --  as the current phase is completed.
   --  ------------------------------
   procedure Response_Completed (Context : in out Faces_Context) is
   begin
      Context.Response_Completed := True;
   end Response_Completed;

   --  ------------------------------
   --  Check whether the response has been completed.
   --  ------------------------------
   function Get_Response_Completed (Context : in Faces_Context) return Boolean is
   begin
      return Context.Response_Completed;
   end Get_Response_Completed;

   --  ------------------------------
   --  Append the message to the list of messages associated with the specified
   --  client identifier.  If <b>Client_Id</b> is empty, the message is global
   --  (or not associated with a component)
   --  ------------------------------
   procedure Add_Message (Context   : in out Faces_Context;
                          Client_Id : in String;
                          Message   : in ASF.Applications.Messages.Message) is

      procedure Append_Message (Key  : in Unbounded_String;
                                List : in out Vectors.Vector);

      --  ------------------------------
      --  Append the message to the list.
      --  ------------------------------
      procedure Append_Message (Key  : in Unbounded_String;
                                List : in out Vectors.Vector) is
         pragma Unreferenced (Key);
      begin
         List.Append (Message);
      end Append_Message;

      Id       : constant Unbounded_String := To_Unbounded_String (Client_Id);
      Severity : constant ASF.Applications.Messages.Severity := Get_Severity (Message);
      Pos      : Message_Maps.Cursor;
      Inserted : Boolean;
   begin
      --  Insert or get the messages associated with the client identifier.
      Context.Messages.Insert (Key      => Id,
                               Position => Pos,
                               Inserted => Inserted);

      --  Append the message in that list.
      Context.Messages.Update_Element (Position => Pos,
                                       Process  => Append_Message'Access);

      if Context.Max_Severity < Severity then
         Context.Max_Severity := Severity;
      end if;
   end Add_Message;

   --  ------------------------------
   --  Append the message to the list of messages associated with the specified
   --  client identifier.  If <b>Client_Id</b> is empty, the message is global
   --  (or not associated with a component)
   --  ------------------------------
   procedure Add_Message (Context   : in out Faces_Context;
                          Client_Id : in String;
                          Message   : in String;
                          Severity  : in Applications.Messages.Severity
                          := Applications.Messages.ERROR) is
      Msg : ASF.Applications.Messages.Message;
   begin
      ASF.Applications.Messages.Set_Severity (Msg, Severity);
      ASF.Applications.Messages.Set_Summary (Msg, Message);
      Context.Add_Message (Client_Id, Msg);
   end Add_Message;

   --  ------------------------------
   --  Get an iterator for the messages associated with the specified client
   --  identifier.  If the <b>Client_Id</b> ie empty, an iterator for the
   --  global messages is returned.
   --  ------------------------------
   function Get_Messages (Context   : in Faces_Context;
                          Client_Id : in String)
                          return ASF.Applications.Messages.Vectors.Cursor is

      Iter : Vectors.Cursor;

      procedure Get_Iterator (Key  : in Unbounded_String;
                              List : in Vectors.Vector);

      --  ------------------------------
      --  Get an iterator for the messages
      --  ------------------------------
      procedure Get_Iterator (Key  : in Unbounded_String;
                              List : in Vectors.Vector) is
         pragma Unreferenced (Key);
      begin
         Iter := List.First;
      end Get_Iterator;

      Id  : constant Unbounded_String := To_Unbounded_String (Client_Id);
      Pos : constant Message_Maps.Cursor := Context.Messages.Find (Id);
   begin
      if Message_Maps.Has_Element (Pos) then
         Message_Maps.Query_Element (Position => Pos,
                                     Process  => Get_Iterator'Access);
      end if;
      return Iter;
   end Get_Messages;

   --  ------------------------------
   --  Returns the maximum severity level recorded for any message that has been queued.
   --  Returns NONE if no message has been queued.
   --  ------------------------------
   function Get_Maximum_Severity (Context : in Faces_Context)
                                  return ASF.Applications.Messages.Severity is
   begin
      return Context.Max_Severity;
   end Get_Maximum_Severity;

   --  ------------------------------
   --  Get a converter from a name.
   --  Returns the converter object or null if there is no converter.
   --  ------------------------------
   function Get_Converter (Context : in Faces_Context;
                           Name    : in EL.Objects.Object)
                           return access ASF.Converters.Converter'Class is
   begin
      return Context.Application.Find (Name);
   end Get_Converter;

   --  ------------------------------
   --  Get the application associated with this faces context.
   --  ------------------------------
   function Get_Application (Context : in Faces_Context)
                             return Application_Access is
   begin
      return Context.Application;
   end Get_Application;

   --  ------------------------------
   --  Get the component view root.
   --  ------------------------------
   function Get_View_Root (Context : in Faces_Context)
                           return ASF.Components.Root.UIViewRoot is
   begin
      return Context.Root;
   end Get_View_Root;

   --  ------------------------------
   --  Get the component view root.
   --  ------------------------------
   procedure Set_View_Root (Context : in out Faces_Context;
                            View    : in ASF.Components.Root.UIViewRoot) is
   begin
      Context.Root := View;
   end Set_View_Root;

   --  ------------------------------
   --  Create an identifier for a component.
   --  ------------------------------
   procedure Create_Unique_Id (Context : in out Faces_Context;
                               Id      : out Natural) is
   begin
      ASF.Components.Root.Create_Unique_Id (Context.Root, Id);
   end Create_Unique_Id;

   --  ------------------------------
   --  Set the exception handler that will receive unexpected exceptions and process them.
   --  ------------------------------
   procedure Set_Exception_Handler (Context : in out Faces_Context;
                                    Handler : in Exceptions.Exception_Handler_Access) is
   begin
      Context.Except_Handler := Handler;
   end Set_Exception_Handler;

   --  ------------------------------
   --  Get the exception handler.
   --  ------------------------------
   function Get_Exception_Handler (Context : in Faces_Context)
                                   return Exceptions.Exception_Handler_Access is
   begin
      return Context.Except_Handler;
   end Get_Exception_Handler;

   --  ------------------------------
   --  Queue an exception event to the exception handler associated with the context.
   --  The exception event will be processed at the end of the current ASF phase.
   --  ------------------------------
   procedure Queue_Exception (Context : in out Faces_Context;
                              Ex      : in Ada.Exceptions.Exception_Occurrence) is
   begin
      if Context.Except_Queue = null then
         Context.Except_Queue := new ASF.Contexts.Exceptions.Exception_Queue;
      end if;
      Context.Except_Queue.Queue_Exception (Ex);
   end Queue_Exception;

   --  ------------------------------
   --  Iterate over the exceptions that have been queued and execute the <b>Process</b>
   --  procedure.  When the procedure returns True in <b>Remove</b, the exception event
   --  is removed from the queue.  The procedure can update the faces context to add some
   --  error message or redirect to an error page.
   --
   --  The application exception handler uses this procedure to process the exceptions.
   --  The exception handler is called after each ASF phase.
   --  ------------------------------
   procedure Iterate_Exception (Context : in out Faces_Context'Class;
                                Process : not null access
                                  procedure (Event   : in Events.Exceptions.Exception_Event'Class;
                                             Remove  : out Boolean;
                                             Context : in out Faces_Context'Class)) is
   begin
      if Context.Except_Queue /= null then
         ASF.Contexts.Exceptions.Iterate (Context.Except_Queue.all, Context, Process);
      end if;
   end Iterate_Exception;

   --  ------------------------------
   --  Returns True if the current request is an AJAX request.
   --  ------------------------------
   function Is_Ajax_Request (Context : in Faces_Context'Class) return Boolean is
   begin
      return Context.Ajax;
   end Is_Ajax_Request;

   --  ------------------------------
   --  Set the Ajax request status.
   --  ------------------------------
   procedure Set_Ajax_Request (Context : in out Faces_Context'Class;
                               Status  : in Boolean) is
   begin
      Context.Ajax := Status;
   end Set_Ajax_Request;

   --  ------------------------------
   --  Get the current faces context.  The faces context is saved
   --  in a per-thread/task attribute.
   --  ------------------------------
   function Current return Faces_Context_Access is
   begin
      return Task_Context.Value;
   end Current;

   --  ------------------------------
   --  Set the current faces context in the per-thread/task attribute.
   --  ------------------------------
   procedure Set_Current (Context     : in Faces_Context_Access;
                          Application : in Application_Access) is
   begin
      Context.Application := Application;
      Task_Context.Set_Value (Context);
   end Set_Current;

   --  ------------------------------
   --  Restore the previous faces context.
   --  ------------------------------
   procedure Restore (Context : in Faces_Context_Access) is
   begin
      Task_Context.Set_Value (Context);
   end Restore;

   --  ------------------------------
   --  Release any storage held by this context.
   --  ------------------------------
   overriding
   procedure Finalize (Context : in out Faces_Context) is
      procedure Free is
         new Ada.Unchecked_Deallocation (Object => ASF.Contexts.Exceptions.Exception_Queue,
                                         Name   => Exception_Queue_Access);
   begin
      if Context.Except_Queue /= null then
         Free (Context.Except_Queue);
      end if;
   end Finalize;

end ASF.Contexts.Faces;