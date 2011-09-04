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

with ASF.Requests;
with ASF.Responses;
with ASF.Sessions;
limited with ASF.Converters;
with ASF.Components.Root;
limited with ASF.Applications.Main;
with ASF.Applications.Messages;
with ASF.Applications.Messages.Vectors;
with ASF.Contexts.Writer;
with EL.Objects;
with EL.Contexts;
with Ada.Strings.Unbounded;

private with Ada.Finalization;
private with Ada.Strings.Unbounded.Hash;
private with Ada.Containers.Hashed_Maps;

--  The <b>Faces_Context</b> is an object passed to the component tree and
--  bean actions to provide the full context in which the view is rendered
--  or evaluated.  The faces context gives access to the bean variables,
--  the request and its parameters, the response writer to write on the
--  output stream.
--
--  The <b>Faces_Context</b> is never shared: it is specific to each request.
package ASF.Contexts.Faces is

   use Ada.Strings.Unbounded;

   type Faces_Context is tagged limited private;

   type Faces_Context_Access is access all Faces_Context'Class;

   --  Get the response writer to write the response stream.
   function Get_Response_Writer (Context : Faces_Context)
     return ASF.Contexts.Writer.ResponseWriter_Access;

   --  Set the response writer to write to the response stream.
   procedure Set_Response_Writer (Context : in out Faces_Context;
                                  Writer  : in ASF.Contexts.Writer.ResponseWriter_Access);

   --  Get the EL context for evaluating expressions.
   function Get_ELContext (Context : in Faces_Context)
                           return EL.Contexts.ELContext_Access;

   --  Set the EL context for evaluating expressions.
   procedure Set_ELContext (Context   : in out Faces_Context;
                            ELContext : in EL.Contexts.ELContext_Access);

   --  Set the attribute having given name with the value.
   procedure Set_Attribute (Context : in out Faces_Context;
                            Name    : in String;
                            Value   : in EL.Objects.Object);

   --  Set the attribute having given name with the value.
   procedure Set_Attribute (Context : in out Faces_Context;
                            Name    : in Unbounded_String;
                            Value   : in EL.Objects.Object);

   --  Get a request parameter
   function Get_Parameter (Context : Faces_Context;
                           Name    : String) return String;

   --  Get the session associated with the current faces context.
   function Get_Session (Context : in Faces_Context;
                         Create  : in Boolean := False) return ASF.Sessions.Session;

   --  Get the request
   function Get_Request (Context : Faces_Context) return ASF.Requests.Request_Access;

   --  Set the request
   procedure Set_Request (Context : in out Faces_Context;
                          Request : in ASF.Requests.Request_Access);

   --  Get the response
   function Get_Response (Context : Faces_Context) return ASF.Responses.Response_Access;

   --  Set the response
   procedure Set_Response (Context  : in out Faces_Context;
                           Response : in ASF.Responses.Response_Access);

   --  Signal the JavaServer faces implementation that, as soon as the
   --  current phase of the request processing lifecycle has been completed,
   --  control should be passed to the <b>Render Response</b> phase,
   --  bypassing any phases that have not been executed yet.
   procedure Render_Response (Context : in out Faces_Context);

   --  Check whether the <b>Render_Response</b> phase must be processed immediately.
   function Get_Render_Response (Context : in Faces_Context) return Boolean;

   --  Signal the JavaServer Faces implementation that the HTTP response
   --  for this request has already been generated (such as an HTTP redirect),
   --  and that the request processing lifecycle should be terminated as soon
   --  as the current phase is completed.
   procedure Response_Completed (Context : in out Faces_Context);

   --  Check whether the response has been completed.
   function Get_Response_Completed (Context : in Faces_Context) return Boolean;

   --  Append the message to the list of messages associated with the specified
   --  client identifier.  If <b>Client_Id</b> is empty, the message is global
   --  (or not associated with a component)
   procedure Add_Message (Context   : in out Faces_Context;
                          Client_Id : in String;
                          Message   : in ASF.Applications.Messages.Message);

   --  Append the message to the list of messages associated with the specified
   --  client identifier.  If <b>Client_Id</b> is empty, the message is global
   --  (or not associated with a component)
   procedure Add_Message (Context   : in out Faces_Context;
                          Client_Id : in String;
                          Message   : in String;
                          Severity  : in Applications.Messages.Severity
                          := Applications.Messages.ERROR);

   --  Get an iterator for the messages associated with the specified client
   --  identifier.  If the <b>Client_Id</b> ie empty, an iterator for the
   --  global messages is returned.
   function Get_Messages (Context   : in Faces_Context;
                          Client_Id : in String) return ASF.Applications.Messages.Vectors.Cursor;

   --  Returns the maximum severity level recorded for any message that has been queued.
   --  Returns NONE if no message has been queued.
   function Get_Maximum_Severity (Context : in Faces_Context)
                                  return ASF.Applications.Messages.Severity;

   --  Get a converter from a name.
   --  Returns the converter object or null if there is no converter.
   function Get_Converter (Context : in Faces_Context;
                           Name    : in EL.Objects.Object)
                           return access ASF.Converters.Converter'Class;

   --  Get the application associated with this faces context.
   function Get_Application (Context : in Faces_Context)
                             return access ASF.Applications.Main.Application'Class;

   --  Get the component view root.
   function Get_View_Root (Context : in Faces_Context)
                           return ASF.Components.Root.UIViewRoot;

   --  Get the component view root.
   procedure Set_View_Root (Context : in out Faces_Context;
                            View    : in ASF.Components.Root.UIViewRoot);

   --  Create an identifier for a component.
   procedure Create_Unique_Id (Context : in out Faces_Context;
                               Id      : out Natural);

   --  Get the current faces context.  The faces context is saved
   --  in a per-thread/task attribute.
   function Current return Faces_Context_Access;

   --  Set the current faces context in the per-thread/task attribute.
   procedure Set_Current (Context     : Faces_Context_Access;
                          Application : access ASF.Applications.Main.Application'Class);

   --  Restore the previous faces context.
   procedure Restore (Context : in Faces_Context_Access);

private

   use ASF.Applications.Messages;

   --  Map of messages associated with a component
   package Message_Maps is new
     Ada.Containers.Hashed_Maps (Key_Type        => Unbounded_String,
                                 Element_Type    => Vectors.Vector,
                                 Hash            => Hash,
                                 Equivalent_Keys => "=",
                                 "="             => Vectors."=");

   type Faces_Context is new Ada.Finalization.Limited_Controlled with record
      --  The response writer.
      Writer   : ASF.Contexts.Writer.ResponseWriter_Access;

      --  The expression context;
      Context  : EL.Contexts.ELContext_Access;

      --  The request
      Request  : ASF.Requests.Request_Access;

      --  The response
      Response : ASF.Responses.Response_Access;

      --  The application
      Application : access ASF.Applications.Main.Application'Class;

      Render_Response    : Boolean := False;
      Response_Completed : Boolean := False;

      --  List of messages added indexed by the client identifier.
      Messages           : Message_Maps.Map;

      --  The maximum severity for the messages that were collected.
      Max_Severity       : Severity := NONE;

      Root               : ASF.Components.Root.UIViewRoot;
   end record;

end ASF.Contexts.Faces;
