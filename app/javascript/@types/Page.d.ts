declare namespace Page {
  interface Attributes {
    id?: number;
    locale: string;
    name: string;
    parent_page_id?: number;
    published_at?: Date;
    pinned?: boolean;
    status?: number;
    news_page?: boolean;
    param?: string;
    editing?: boolean;
  }

  interface Node extends Attributes, Tree.Node {
    children: Node[];
    permissions?: string[];
  }
}
