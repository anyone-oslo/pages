import { TreeNode } from "../../lib/Tree";

export type Attributes = Record<string, unknown>;

export interface PageNode extends TreeNode {
  id: number | null;
  children: PageNode[];
  editing: boolean;
  locale: string;
  name: string;
  param: string;
  permissions: string[];
  published_at: string;
  status: string;
}
