-----------------------------------------------------------------------
--  components-core -- ASF Core Components
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

package body ASF.Components.Core is

   use ASF;
   use EL.Objects;

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
      return UI.Id;
   end Get_Client_Id;

   procedure Encode_Begin (UI      : in UIText;
                           Context : in out Faces_Context'Class) is
   begin
      UI.Text.Encode_All (Context);
   end Encode_Begin;

   function Create_UIText (Tag : ASF.Views.Nodes.Text_Tag_Node_Access)
                           return UIComponent_Access is
      Result : constant UIText_Access := new UIText;
   begin
      Result.Text := Tag;
      return Result.all'Access;
   end Create_UIText;

   --  ------------------------------
   --  Get the root node of the view.
   --  ------------------------------
   function Get_Root (UI : UIViewRoot) return UIComponent_Access is
   begin
      return UI.Root;
   end Get_Root;

   --  ------------------------------
   --  Set the root node of the view.
   --  ------------------------------
   procedure Set_Root (UI   : in out UIViewRoot;
                       Root : in out UIComponent'Class) is
   begin
      if UI.Root /= null then
         Delete (UI.Root);
      end if;
      if Root.First_Child = null then
         UI.Root := null;
      elsif Root.First_Child.Next = null then
         UI.Root := Root.First_Child;
         Root.First_Child := null;
         Root.Last_Child  := null;
      else
         UI.Root := new UIComponentBase;
         UI.Root.First_Child := Root.First_Child;
         UI.Root.Last_Child  := Root.Last_Child;
         Root.First_Child := null;
         Root.Last_Child  := null;
      end if;
   end Set_Root;

   --  Free the memory held by the component tree.
   overriding
   procedure Finalize (Object : in out UIViewRoot) is
   begin
      if Object.Root /= null then
         Delete (Object.Root);
      end if;
   end Finalize;

   overriding
   procedure Encode_Begin (UI      : in UIView;
                           Context : in out Faces_Context'Class) is
   begin
      null;
   end Encode_Begin;

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
   function Get_Parameters (UI : UIComponent'Class) return UIParameter_Access_Array is

      Result : UIParameter_Access_Array (1 .. UI.Get_Children_Count);
      Last   : Natural := 0;

      procedure Collect (Child : in UIComponent_Access);
      pragma Inline (Collect);

      procedure Collect (Child : in UIComponent_Access) is
      begin
         if Child.all in UIParameter'Class then
            Last := Last + 1;
            Result (Last) :=  UIParameter (Child.all)'Access;
         end if;
      end Collect;

      procedure Iter is new ASF.Components.Iterate (Process => Collect);
      pragma Inline (Iter);

   begin
      Iter (UI);
      return Result (1 .. Last);
   end Get_Parameters;

end ASF.Components.Core;
