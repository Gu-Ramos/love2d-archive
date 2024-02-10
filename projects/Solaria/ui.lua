local tbl = {}
function tbl:draw(dt)
  if self.state.main == 'menu' then
    if Suit.Button('Singleplayer',{cornerRadius=50, color=self.color.base, drawMode='line',font=Assets.font.TurretRoad},410,830,500,100).hit then
      self.state.main = 'game'
    end
    if Suit.Button('Multiplayer',{cornerRadius=50, color=self.color.base, drawMode='line',font=Assets.font.TurretRoad},1010,830,500,100).hit then
    end
    Suit.Label('solAriA',{font=Assets.font.MajorMono,color=self.color.blank, mesh=Data.TitleMesh},610,430,700,100)
  end
end

return tbl

