export interface AgentData {
  x: number;
  y: number;
  size: number;
  color: string;
}

export default class AgentLayer {
  private visible: boolean = true;
  private agents: AgentData[] = [];
  private animationFrame: number = 0;

  setAgents(agents: AgentData[]): void {
    this.agents = agents;
  }

  addAgent(agent: AgentData): void {
    this.agents.push(agent);
  }

  render(ctx: CanvasRenderingContext2D): void {
    this.agents.forEach(agent => {
      this.drawAgent(ctx, agent);
    });

    this.animationFrame++;
  }

  private drawAgent(ctx: CanvasRenderingContext2D, agent: AgentData): void {
    ctx.fillStyle = agent.color;
    ctx.beginPath();

    const wobble = Math.sin(this.animationFrame * 0.1) * 2;
    ctx.arc(agent.x + wobble, agent.y, agent.size, 0, Math.PI * 2);

    ctx.fill();

    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  isVisible(): boolean {
    return this.visible;
  }

  setVisible(visible: boolean): void {
    this.visible = visible;
  }

  clear(): void {
    this.agents = [];
  }

  invalidate(x: number, y: number, width: number, height: number): void {
  }
}
